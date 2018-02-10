# Fast Integration Tests with Clearance::Backdoor

It is common in web application integration tests
to require a signed in user.
We could write RSpec and Capybara tests for a Rails application like this:

```ruby
visit root_path
fill_in "Email", with: "user@example.com"
fill_in "Password", with: "password"
click_on "Sign In"
# ...
```

This is redundant and makes the test suite slow
if we write the same setup for every test that requires a signed in user.

If we're using [Clearance] in the Rails app,
we can use a [back door] to insert Rack middleware that
avoids wasting time spent visiting, loading, and submitting the sign in form.
It instead signs in the designated user directly.

[Clearance]: http://github.com/thoughtbot/clearance
[back door]: http://xunitpatterns.com/back%20door.html

In config/environments/test.rb:

```
MyRailsApp::Application.configure do
  # ...
  config.middleware.use Clearance::BackDoor
  # ...
end
```

Then, include a user in an `as` parameter in integration tests:

```
visit dashboard_path(as: user)
```

It works for any URL:

```
visit new_feedback_path(as: giver)
```

The speed increase can be substantial.
On one project using this technique,
the test suite time was reduced 23%.
