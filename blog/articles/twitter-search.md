# Twitter Search

[Twitter Search] (formerly Summize) is sweet.
I use it every day to find first-person commentary on thoughtbot's work,
Boston sports, national politics, or anything else that catches my fancy.

[Twitter Search]: https://twitter.com/search-home

The [Twitter Search API] is also sweet.
I wanted to use it for Politweets, a side project,
to aggregate tweets on the U.S. presidential election
from around the world within minutes of being published.

[Twitter Search API]: http://search.twitter.com/api

[Dustin Sallings] published a Ruby wrapper for the Summize API on GitHub.
I forked it and added a test suite and documentation.

[Dustin Sallings]: https://github.com/dustin

Introducing the Twitter Search gem!
(Update: The Twitter Search gem was later merged into the [Twitter gem].)

[Twitter gem]: https://github.com/sferik/twitter

## Usage

Install the gem.

```ruby
gem install twitter-search
```

Require the gem.

```ruby
require "twitter_search"
```

Set up a `TwitterSearch::Client`.
Name your client (a.k.a. "user agent") to something meaningful,
such as your app's name.
This helps Twitter Search answer any questions about your use of the API.

```ruby
@client = TwitterSearch::Client.new("politweets")
```

Request tweets by calling the query method of your client.

```ruby
@tweets = @client.query(:q => "twitter search")
```

## Search Operators

The following operator examples find tweets...

* [twitter search](https://twitter.com/search?q=twitter+search)
  containing both twitter and search. This is the default operator.
* [happy hour](https://twitter.com/search?q=%22happy+hour%22)
  containing the exact phrase happy hour.
* [obama OR hillary](https://twitter.com/search?q=obama+OR+hillary)
  containing either obama or hillary (or both).
* [beer -root](https://twitter.com/search?q=beer+-root)
  containing beer but not root.
* [#haiku](https://twitter.com/search?q=%23haiku) containing
  the hashtag haiku.
* [from:croaky](https://twitter.com/search?q=from%3Acroaky)
  sent from person croaky.
* [to:techcrunch](https://twitter.com/search?q=to%3Atechcrunch)
  sent to person techcrunch.
* [@mashable](https://twitter.com/search?q=%40mashable)
  referencing person mashable.
* [superhero since:2008-05-01](https://twitter.com/search?q=superhero+since%3A2008-05-01)
  containing superhero and sent since date 2008-05-01 (year-month-day).
* [ftw until:2008-05-03](https://twitter.com/search?q=ftw+until%3A2008-05-03)
  containing ftw and sent up to date 2008-05-03.
* [movie -scary :)](https://twitter.com/search?q=movie+-scary+%3A%29)
  containing movie, but not scary, and with a positive attitude.
* [flight :(](https://twitter.com/search?q=flight+%3A%28)
  containing flight and with a negative attitude.
* [traffic ?](https://twitter.com/search?q=traffic+%3F)
  containing traffic and asking a question.
* [hilarious filter:links](https://twitter.com/search?q=hilarious+filter%3Alinks)
  containing hilarious and linking to URLs.

## Foreign Languages

The Twitter Search API supports foreign languages,
accessible via the `:lang` key.
Use an [ISO 639-1] code as the value:

[ISO 639-1]: http://en.wikipedia.org/wiki/ISO_639-1

```ruby
@tweets = @client.query(:q => "programmé", :lang => "fr")
```

## Result pagination

Alter the number of Tweets returned per page with the `:rpp` key.
Stick with 10, 15, 20, 25, 30, or 50.

```ruby
@tweets = @client.query(:q => "Boston Celtics", :rpp => "30")
```

## Gotchas

Searching for a positive attitude :) returns tweets containing the text :),
=), :D, and :-)

Searches are case-insensitive.

The `near` operator available in the Twitter Search web interface
is not available via the API:
You must geocode before making the API call
and use the `:geocode` key in the request
using the pattern `lat,lngmi` or `lat,lngkm`:

```ruby
@tweets = @client.query(:q => "Pearl Jam", :geocode => "43.4411,-70.9846mi")
```

## Usage with ActiveRecord and Cron

You can get fancier with your setup,
using queuing or another approach,
but here's an example using cron.

Schema:

```ruby
create_table "tweets", :force => true do |t|
  t.string   "user_name",          :limit => 20,  :default => "", :null => false
  t.string   "body",               :limit => 140, :default => "", :null => false
  t.datetime "created_at",                                        :null => false
  t.datetime "updated_at",                                        :null => false
  t.integer  "twitter_id",         :limit => 11
end

add_index "tweets", ["created_at"], :name => "index_tweets_on_created_at"
add_index "tweets", ["twitter_id"], :name => "index_tweets_on_twitter_id"
```

Request the API from a rake task,
keeping the logic [in a class so it can be easily tested][class]:

[class]: http://blog.jayfields.com/2006/11/ruby-testing-rake-tasks.html

```ruby
class Twitter
  def self.import!
    # the implementation is up to you
  end
end
```

Since I don't have the cron API memorized,
I like to define cron jobs with [crondle]:

[crondle]: http://github.com/scrooloose/crondle

```ruby
require "lib/crondle"

Crondle.define_jobs do |builder|
  rails_root = "/var/www/apps/politweets/current"

  [3, 9, 15, 21, 27, 33, 39, 45, 51, 57].each do |minute|
    builder.desc "Import tweets at #{minute} past the hour"
    builder.job "#{rails_root}/script/runner Twitter.import!", :minute => minute
  end
end
```

Run the crondle script to get the text to enter into `crontab -e`:

```
# Import tweets at 3 past the hour
3 * * * * /var/www/apps/politweets/current/script/runner Twitter.import!

# Import tweets at 9 past the hour
9 * * * * /var/www/apps/politweets/current/script/runner Twitter.import!
```

And you're on your way.

Thanks to [Doug](http://www.doug-march.com/),
[Gabe](http://ducktyper.com/),
[Jason](http://sixtwothree.org/),
[Min](http://www.thoughtsatsix.com/), and
[Dustin](http://bleu.west.spy.net/~dustin/)
for their work on Politweets and the Twitter Search gem.
