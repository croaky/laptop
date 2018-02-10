# Four-Phase Test

The [Four-Phase Test] is a testing pattern,
applicable to all programming languages and unit tests
(but not integration tests).

[Four-Phase Test]: http://xunitpatterns.com/Four%20Phase%20Test.html

It takes the following general form:

```ruby
test do
  setup
  exercise
  verify
  teardown
end
```

There are four distinct phases of the test.
They are executed sequentially.

## Setup

During setup,
the system under test (usually a class, object, or method) is set up:

```ruby
user = User.new(password: "password")
```

## Exercise

During exercise, the system under test is exercised:

```ruby
user.save
```

## Verify

During verification,
the result of the exercise is verified against the developer's expectations:

```ruby
expect(user.encrypted_password).to_not be_nil
```

## Teardown

During teardown,
the system under test is reset to its pre-setup state.

This is usually handled implicitly by the language (releasing memory)
or test framework (running inside a database transaction).

## All together

The four phases are wrapped into a named test to be referenced individually.

A related [style guideline] advises we
"Separate setup, exercise, verification, and teardown phases with newlines."

[style guideline]: https://github.com/thoughtbot/guides/tree/master/style

```ruby
describe "#save" do
  it "encrypts the password" do
    user = User.new(password: "password")

    user.save

    expect(user.encrypted_password).to_not be_nil
  end
end
```

Go forth and test in phases.
