# DNS to CDN to Origin

Content Distribution Networks (CDNs) such as
[Amazon CloudFront][cloudfront] and [Fastly][fastly]
pull content from their [origin server] during HTTP requests to cache them:

[cloudfront]: http://aws.amazon.com/cloudfront/
[fastly]: http://www.fastly.com/
[origin server]: http://www.w3.org/Protocols/rfc2616/rfc2616-sec1.html#sec1.3

```
DNS -> CDN -> Origin
```

Examples:

```
DNSimple -> Fastly -> Heroku
DNSimple -> Cloudfront -> Heroku
Route 53 -> CloudFront -> S3
Route 53 -> CloudFront -> EC2
Route 53 -> CloudFront -> ELB -> EC2
```

## Without an asset host

If a `CNAME` record for a domain name points to a Rails app on Heroku:

```
www.example.com -> example.herokuapp.com
```

Each HTTP request for a static asset:

* is received by the [Heroku routing mesh][mesh] (platform load balancer)
* picked up by a web dyno (host)
* passed to one of the [Puma workers][puma] (web server process) on the dyno
* routed by Rails to the asset (CSS, JS, img, font file)

[mesh]: https://devcenter.heroku.com/articles/http-routing
[puma]: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server

The logs will contain lines like this:

```
GET "/assets/application-ql4h2308y.js"
GET "/assets/application-ql4h2308y.css"
```

This isn't the best use of Ruby processes;
they should be reserved for handling application logic.
Response time is degraded by waiting for processes
to finish their work.

## With a CDN as an asset host

In production,
Rails' [asset pipeline] appends a hash of each asset's contents
to the asset's name.
When the file changes,
the browser requests the latest version.

[asset pipeline]: http://guides.rubyonrails.org/asset_pipeline.html

The first time a user requests an asset, it will look like this:

```
GET 123abc.cloudfront.net/application-ql4h2308y.css
```

A CloudFront cache miss "pulls from the origin" by making another GET request:

```
GET example.herokuapp.com/application-ql4h2308y.css
```

Future `GET` and `HEAD` requests
to the CloudFront URL within the cache duration
will be cached, with no second HTTP request to the origin:

```
GET 123abc.cloudfront.net/application-ql4h2308y.css
```

All HTTP requests using verbs other than `GET` and `HEAD`
proxy through to the origin, which follows
the [Write-Through Mandatory][write-through] portion of
the HTTP specification.

[write-through]: http://www.w3.org/Protocols/rfc2616/rfc2616-sec13.html#sec13.11

## Rails configuration

In `Gemfile`:

```ruby
gem "sass-rails"
gem "uglifier"
```

In `config/environments/production.rb`:

```ruby
config.action_controller.asset_host = ENV.fetch(
  "ASSET_HOST",
  "https://123abc.cloudfront.net",
)
config.action_mailer.asset_host = config.action_controller.asset_host
config.assets.compile = false
config.assets.digest = true
config.assets.js_compressor = :uglifier
config.public_file_server.enabled = true
config.public_file_server.headers = {
  'Cache-Control' => "public, max-age=#{10.years.to_i}, immutable",
}
```

The [`immutable` directive][immutable] eliminates revalidation requests.

[immutable]: https://code.facebook.com/posts/557147474482256/this-browser-tweak-saved-60-of-requests-to-facebook/

## CloudFront setup

To use CloudFront:

* "Download" CloudFront distribution
* "Origin Domain Name" as `www.example.com`
* "Origin Protocol Policy" to "Match Viewer"
* "Object Caching" to "Use Origin Cache Headers"
* "Forward Query Strings" to "No (Improves Caching)"
* "Distribution State" to "Enabled"

## Fastly setup

To use Fastly, there's no additional "Origin Pull" configuration.

This is a handy task for the app's `Rakefile`:

```ruby
task :purge do
  api_key = ENV["FASTLY_KEY"]
  site_key = ENV["FASTLY_SITE_KEY"]
  `curl -X POST -H 'Fastly-Key: #{api_key}' https://api.fastly.com/service/#{site_key}/purge_all`
  puts 'Cache purged'
end
```

Then, the deployment process can be adjusted to:

```bash
git push heroku master --app example
heroku run rake purge --app example
```

For more advanced caching and cache invalidation at an object level,
see the [fastly-rails] gem.

[fastly-rails]: https://github.com/fastly/fastly-rails

## Caching entire HTML pages

Setting the asset host is the most important low-hanging fruit.
In some cases,
it can also make sense to use a DNS to CDN to Origin architecture
to cache entire HTML pages.

Here's an example at the Rails controller level:

```ruby
class PagesController < ApplicationController
  before_filter :set_cache_headers

  private

  def set_cache_headers
    response.headers["Surrogate-Control"] = "max-age=#{10.years.to_i}"
  end
end
```

To cache entire HTML pages in the CDN,
use the [`Surrogate-Control` response header][surrogate].

[surrogate]: http://www.w3.org/TR/edge-arch

The CDN will cache the page for the duration specified,
protecting the origin from unnecessary requests
and serving the HTML from the CDN's edge servers.

To cache entire HTML pages site-wide,
one approach is [Rack](https://rack.github.io/) middleware:

```ruby
module Rack
  class SurrogateControl
    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, body = @app.call(env)
      headers["Cache-Control"] = "public, max-age=#{5.minutes.to_i}"
      headers["Surrogate-Control"] = "max-age=#{10.years.to_i}"
      [status, headers, body]
    end
  end
end
```
