# Fast Integration Tests with Clearance::Backdoor

It is common in web application integration tests
to require a signed in user.
RSpec and Capybara tests for a Rails application could look like this:

```ruby
visit root_path
fill_in "Email", with: "user@example.com"
fill_in "Password", with: "password"
click_on "Sign In"
# ...
```

This is redundant and makes the test suite slow
if we write the same setup for every test that requires a signed in user.

If [Clearance] is being used for authentication,
a [back door] can be inserted as Rack middleware.
Instead of visiting, loading, and submitting the sign in form,
it directly sets the designated user's ID into the session.

[Clearance]: http://github.com/thoughtbot/clearance
[back door]: http://xunitpatterns.com/back%20door.html

In `config/environments/test.rb`:

```ruby
MyRailsApp::Application.configure do
  # ...
  config.middleware.use Clearance::BackDoor
  # ...
end
```

Then, include a user in an `as` parameter in integration tests:

```ruby
visit dashboard_path(as: user)
```

It works for any URL:

```ruby
visit new_feedback_path(as: giver)
```

The speed increase can be substantial.
On one project using this technique,
the test suite time was reduced 23%.
