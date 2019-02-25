# Test Spies vs. Mocks

When we use a [test spy] in our unit tests
instead of a [mock object],
we make some tradeoffs.
This article explores our decisions.

[test spy]: https://thoughtbot.com/blog/spy-vs-spy
[mock object]: http://xunitpatterns.com/Mock%20Object.html

## An example spy

Here is a test written in [RSpec]:

[RSpec]: https://www.relishapp.com/rspec

```ruby
require "spec_helper"

describe PersonFinder, ".json_for" do
  it "notifies Airbrake of Clearbit API exception, returns empty hash" do
    allow(clearbit).to receive(:find).and_raise("a network error")
    allow(Airbrake).to receive(:notify_or_ignore)

    result = PersonFinder.json_for("user@example.com")

    expect(Airbrake).to have_received(:notify_or_ignore)
    expect(result).to eq({}.to_json)
  end

  def clearbit
    Clearbit::Streaming::Person
  end
end
```

This spec describes a `PersonFinder` class
interacting with two collaborators:
`Clearbit::Streaming::Person` for the [Clearbit] API
and `Airbrake` for the [Airbrake] API.

[Clearbit]: https://clearbit.com
[Airbrake]: https://airbrake.io

The spec uses a stub-and-spy approach
by stubbing with [`allow`],
then asserting expectations were met with [`expect`].

[`allow`]: https://github.com/rspec/rspec-mocks#method-stubs
[`expect`]: https://github.com/rspec/rspec-mocks#test-spies

This style helps keep the [Four-Phase Test] in order,
emphasized by the newlines separating
the setup, exercise, and verification phases.

[Four-Phase Test]: four-phase-test

The [system under test] looks like this:

```ruby
class PersonFinder
  def self.json_for(email)
    begin
      person = Clearbit::Streaming::Person.find(email: email)
      person.to_json
    rescue => exception
      Airbrake.notify_or_ignore(exception, parameters: { email: email })
      {}.to_json
    end
  end
end
```

[system under test]: https://thoughtbot.com/blog/don-t-stub-the-system-under-test

[Clearbit's API is reliable][uptime],
but like any other network request,
errors will occur during some percentage of requests
due to issues clients-side, provider-side, or in between.

[uptime]: http://status.clearbit.com/#month

## Alternate approach with mocking

An alternate style for the test,
using mocks,
could look like this:

```ruby
describe PersonFinder, ".json_for" do
  it "notifies Airbrake of Clearbit API exception, returns empty hash" do
    allow(clearbit).to receive(:find).and_raise("a network error")
    expect(Airbrake).to receive(:notify_or_ignore)

    result = PersonFinder.json_for("user@example.com")

    expect(result).to eq({}.to_json)
  end

  def clearbit
    Clearbit::Streaming::Person
  end
end
```

This style uses an expectation-first mock.
The phases of the test are now "setup, verify, exercise, verify",
which is sometimes confusing when we read the code.

On the positive side, we have eliminated some duplication.

## Spies without duplication

RSpec 3.1 introduces a [`spy` method] that looks like this:

[`spy` method]: https://relishapp.com/rspec/rspec-mocks/docs/basics/spies

The implementation of `spy` is:

```ruby
def spy(*args)
  double(*args).as_null_object
end
```

This means we don't have to stub
any method invocations
that occur in our test run.

Consider another example without `spy`:

```ruby
describe "updating credit card details" do
  it "saves the credit card with Stripe" do
    stripe_customer = double("Stripe::Customer", :card= => nil, save: nil)
    allow(Stripe::Customer).to receive(:retrieve).and_return(stripe_customer)
    token = "fake token"

    post :update, stripe_token: token

    expect(stripe_customer).to have_received(:card=).with(token)
    expect(stripe_customer).to have_received(:save)
  end
end
```

We duplicate the methods `#card=` and `#save`
during the setup and verification phases.
We add no extra information to the test
in the setup phase.

Let's refactor that line to use `spy`:

```ruby
stripe_customer = spy("Stripe::Customer")
```

Pre-RSpec 3.2, we could have alternatively written:

```ruby
stripe_customer = double("Stripe Customer").as_null_object
```

Both versions eliminate the duplicated method stubs.

The `spy` version is more informative
because it tells us this object's purpose.
We will asserting an expectation on the object later.

## Tradeoffs

The one downside of
`spy` and `as_null_object` are that
they have the potential to hide bloated APIs.
Pure mocks require that we stub out each method
that will be called during the test.
The noise created by writing those stubs
is a hint that we could improve the implementation.

Mocks have more downsides.
They are more difficult to re-use,
they break the linear readability of the Four-Phase test,
and can lead to over-testing.

Spies are therefore a more lightweight way
to verify a side effect.
When spies are available in a project's testing tools,
I don't use mocks.
