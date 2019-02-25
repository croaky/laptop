# Test HTTP Errors

A common pattern in apps is handling failure by
notifying an error-catching service such as [Airbrake].
An example is consuming a third party web service such as Twitter.

[Airbrake]: http://airbrake.io

```ruby
def fetch_tweets(search)
  search.fetch
rescue *(HTTP_ERRORS + Twitter::Search::ERRORS) => error
  Airbrake.notify(error)
  []
end
```

This uses the [Twitter gem]
and sends rescued errors to Airbrake,
shielding users from 500s with relevant copy.

[Twitter gem]: https://github.com/sferik/twitter

## Isolate HTTP calls

The separation of building a query (object initialization)
and making the HTTP request (fetch method)
makes testing failure and other tests easier.
The `fetch_tweets` method can be stubbed and
the interface to the Twitter library can be ignored.

## Arrays of error types

`HTTP_ERRORS` comes from [Suspenders' errors initializer][Suspenders]:

[Suspenders]: https://github.com/thoughtbot/suspenders/blob/master/templates/errors.rb

```ruby
HTTP_ERRORS = [
  EOFError,
  Errno::ECONNRESET,
  Errno::EINVAL,
  Net::HTTPBadResponse,
  Net::HTTPHeaderSyntaxError,
  Net::ProtocolError,
  Timeout::Error,
]
```

`Twitter::Search::ERRORS` is something custom.

## Test failure with stubs and spies

```ruby
*(HTTP_ERRORS + Twitter::Search::ERRORS).each do |error|
  it "notifies hoptoad upon #{error} on fetch tweets" do
    search = double("search")
    an_error = error.new("")
    allow(search).to receive(:fetch).and_raises(an_error)
    allow(Airbrake).to receive(:notify)
    brand = build(:brand)

    brand.fetch_tweets(search)

    expect(Airbrake).to have_received(:notify).with(an_error)
  end
end
```

[Test spies] use the normal [Four-Phase Test] structure.
Newlines separate the setup, exercise, and verification phases.
The test is flat; it does not use a context block.

[test spies]: https://thoughtbot.com/blog/spy-vs-spy
[Four-Phase Test]: four-phase-test
