# DNS to CDN to Origin

Content Distribution Networks (CDNs) such as [Amazon CloudFront][cloudfront] and
[Fastly][fastly] have the ability to "pull" content from their [origin server]
during HTTP requests in order to cache them. They can also proxy POST, PUT,
PATCH, DELETE, and OPTION HTTP requests, which means they can "front" our web
application's origin like this:

[cloudfront]: http://aws.amazon.com/cloudfront/
[fastly]: http://www.fastly.com/
[origin server]: http://www.w3.org/Protocols/rfc2616/rfc2616-sec1.html#sec1.3

    DNS -> CDN -> Origin

Swapping out the concepts for actual services we use, the architecture can look
like this:

    DNSimple -> CloudFront -> Heroku

Or like this:

    DNSimple -> Fastly -> Heroku

Or many other combinations.

## Without Origin Pull or an Asset Host

Let's first examine what it looks like serve static assets (CSS, JavaScript,
font, and image files) from a Rails app without a CDN.

We could point our domain name to our Rails app running on Heroku using a
`CNAME` record ([apex domains in cloud environments have their own set of
eccentricities][apex]):

    www.thoughtbot.com -> thoughtbot-production.herokuapp.com

[apex]: https://devcenter.heroku.com/articles/apex-domains

We'll also need to set the following configuration:

```ruby
# config/environments/{staging,production}.rb
config.serve_static_assets = true
```

In this setup, we'll then see something like the following in our logs:

![no asset host](https://images.thoughtbot.com/dns-cdn-origin/no-asset-host.png)

That screenshot is from development mode but the same effect will occur in
production:

* all the application's requests to static assets will go through the [Heroku
  routing mesh][mesh],
* get picked up by one of our web dynos,
* passed to one of the [Unicorn workers][unicorn] on the dyno,
* then routed by Rails to the asset

[mesh]: https://devcenter.heroku.com/articles/http-routing
[unicorn]: https://devcenter.heroku.com/articles/rails-unicorn

This isn't the best use of our Ruby processes. They should be reserved for
handling real logic. Each process should have the fastest possible response
time. Overall response time is affected by waiting for other processes to finish
their work.

## How Can We Solve This

[AssetSync](https://github.com/rumblelabs/asset_sync) is a popular approach that
we have used in the past with success. We no longer use it because there's no
need to copy all files to S3 during deploy (`rake assets:precompile`). Copying
files across the network is wasteful and slow, and gets slower as the codebase
grows. S3 is also not a CDN, does not have edge servers, and therefore is slower
than CDN options.

## Asset Hosts that Support "Origin Pull"

A better alternative is to use services that "pull" the assets from the origin
(Heroku) "Just In Time" the first time they are needed. Services we've used
include CloudFront and Fastly. Fastly is our usual default due to its amazingly
quick cache invalidation. Both have "origin pull" features that work well with
Rails' asset pipeline.

Because of the asset pipeline, in production, every asset has a hash added to
its name. Whenever the file changes, the browser requests the latest version as
the hash and therefore the whole filename changes.

The first time a user requests an asset, it will look like this:

    GET 123abc.cloudfront.net/application-ql4h2308y.css

A CloudFront cache miss "pulls from the origin" by making another GET request:

    GET your-app-production.herokuapp.com/application-ql4h2308y.css

All future `GET` and `HEAD` requests to the CloudFront URL within the cache
duration will be cached, with no second HTTP request to the origin:

    GET 123abc.cloudfront.net/application-ql4h2308y.css

All HTTP requests using verbs other than `GET` and `HEAD` proxy through to the
origin, which follows the [Write-Through Mandatory][write-through] portion of
the HTTP specification.

[write-through]: http://www.w3.org/Protocols/rfc2616/rfc2616-sec13.html#sec13.11

## Making it Work with Rails

We have standard configuration in our Rails apps that make this work:

```ruby
# Gemfile
gem "coffee-rails"
gem "sass-rails"
gem "uglifier"

group :staging, :production do
  gem "rails_12factor"
end

# config/environments/{staging,production}.rb:
config.action_controller.asset_host = ENV["ASSET_HOST"] # will look like //123abc.cloudfront.net
config.assets.compile = false
config.assets.digest = true
config.assets.js_compressor = :uglifier
config.assets.version = ENV["ASSETS_VERSION"]
config.static_cache_control = "public, max-age=#{1.year.to_i}"
```

We don't have to manually set `config.serve_static_assets = true` because the
[`rails_12factor`][12factor] gem does it for us, in addition to handling any
other current or future Heroku-related settings.

[12factor]: https://github.com/heroku/rails_12factor

Fastly and other [reverse proxy caches][reverse] respect [the
`Surrogate-Control` standard][surrogate]. To get entire HTML pages cached in
Fastly, we only need to include the `Surrogate-Control` header in the response.
Fastly will cache the page for the duration we specify, protecting the origin
from unnecessary requests and serving the HTML from Fastly's edge servers.

[reverse]: http://en.wikipedia.org/wiki/Reverse_proxy
[surrogate]: http://www.w3.org/TR/edge-arch

## Caching Entire HTML Pages (Why Use Memcache?)

While setting the asset host is a great start, a DNS to CDN to Origin
architecture also lets us cache entire HTML pages. Here's an example of caching
entire HTML pages in Rails with [High Voltage]:

[High Voltage]: https://github.com/thoughtbot/high_voltage

```ruby
class PagesController < HighVoltage::PagesController
  before_filter :set_cache_headers

  private

  def set_cache_headers
    response.headers["Surrogate-Control"] = "max-age=#{1.day.to_i}"
  end
end
```

This will allow us to cache entire HTML pages in the CDN without using a
Memcache add-on, which still goes through the Heroku router, then our app's web
processes, then Memcache. This architecture entirely protects the Rails app from
HTTP requests that don't require Ruby logic specific to our domain.

## Rack Middleware

If we want to cache entire HTML pages site-wide, we might want to use [Rack]
middleware. Here's our typical `config.ru` for a [Middleman] app:

[Rack]: http://rack.github.io/
[Middleman]: http://middlemanapp.com/

```ruby
$:.unshift File.dirname(__FILE__)

require "rack/contrib/try_static"
require "lib/rack_surrogate_control"

ONE_WEEK = 604_800
FIVE_MINUTES = 300

use Rack::Deflater
use Rack::SurrogateControl
use Rack::TryStatic,
  root: "tmp",
  urls: %w[/],
  try: %w[.html index.html /index.html],
  header_rules: [
    [
      %w(css js png jpg woff),
      { "Cache-Control" => "public, max-age=#{ONE_WEEK}" }
    ],
    [
      %w(html), { "Cache-Control" => "public, max-age=#{FIVE_MINUTES}" }
    ]
  ]

run lambda { |env|
  [
    404,
    {
      "Content-Type"  => "text/html",
      "Cache-Control" => "public, max-age=#{FIVE_MINUTES}"
    },
    File.open("tmp/404.html", File::RDONLY)
  ]
}
```

We build the Middleman app at `rake assets:precompile` time during deploy to
Heroku, as described in [Styling a Middleman Blog with Bourbon, Neat, and
Bitters][styling]. In production, we serve the app using Rack, so we are able
to insert middleware to handle the `Surrogate-Control` header:

[styling]: https://robots.thoughtbot.com/middleman-bourbon-walkthrough

```ruby
module Rack
  class SurrogateControl
    # Cache content in a reverse proxy cache (such as Fastly) for a year.
    # Use Surrogate-Control in response header so cache can be busted after
    # each deploy.
    ONE_YEAR = 31557600

    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, body = @app.call(env)
      headers["Surrogate-Control"] = "max-age=#{ONE_YEAR}"
      [status, headers, body]
    end
  end
end
```

## CloudFront Setup

If we want to use CloudFront, we use the following settings:

* "Download" CloudFront distribution
* "Origin Domain Name" as www.thoughtbot.com (our app's URL)
* "Origin Protocol Policy" to "Match Viewer"
* "Object Caching" to "Use Origin Cache Headers"
* "Forward Query Strings" to "No (Improves Caching)"
* "Distribution State" to "Enabled"

As a side benefit, in combination with [CloudFront logging][logging], we could
[replay HTTP requests][replay] on the Rails app if we had downtime at the origin
for any reason, such as a Heroku platform issue.

[logging]: http://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/AccessLogs.html
[replay]: http://success.heroku.com/levelup

## Fastly Setup

If we use Fastly instead of CloudFront, there's no "Origin Pull" configuration
we need to do. It will work "out of the box" with our Rails configuration settings.

We often have a rake task in our Ruby apps fronted by Fastly like this:

```ruby
# Rakefile
task :purge do
  api_key = ENV["FASTLY_KEY"]
  site_key = ENV["FASTLY_SITE_KEY"]
  `curl -X POST -H 'Fastly-Key: #{api_key}' https://api.fastly.com/service/#{site_key}/purge_all`
  puts 'Cache purged'
end
```

That turns our deployment process into:

```bash
git push production
heroku run rake purge --remote production
```

For more advanced caching and cache invalidation at an object level, see the
[fastly-rails] gem.

[fastly-rails]: https://github.com/fastly/fastly-rails

## Back to the Future

Fastly is really "Varnish as a Service". Early in its history, Heroku used to
include [Varnish](http://www.varnish-software.com) (an awesome open source
reverse proxy) as a standard part of its "Bamboo" stack. When they decoupled the
reverse proxy in their "Cedar" stack, we gained the flexibility of using
different reverse proxy caches and CDNs fronting Heroku.

[Varnish]: https://www.varnish-cache.org/

## Love is Real

We have been using this stack in production for
[the thoughtbot website][home] (a Rails app),
[blog][blog] (a Middleman app),
and many other
apps for almost a year. It's a stack in real use and is strong enough to
consider as a good default architecture.

Give it a try on your next app!

[home]: https://thoughtbot.com
[blog]: https://robots.thoughtbot.com
