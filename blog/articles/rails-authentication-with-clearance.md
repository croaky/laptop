# Rails Authentication with Clearance

Authentication is a common pattern in Rails apps.
We've used plugins such as `acts_as_authenticated` and `restful_authentication`
and wrote authentication from scratch on our clients' apps for a year.

We then extracted [Hoptoad]'s authentication into a gem,
and merged relevant code from two of our clients' apps.
We named the gem [Clearance]
and are happy to announce its official release.

[Hoptoad]: http://hoptoadapp.com
[Clearance]: http://github.com/thoughtbot/clearance

Clearance adds these features to your Rails app:

- Sign up
- Confirm email
- Sign in
- Sign out
- Reset password

Get it on [GitHub][Clearance].

## Modules, Shoulda, and Factory Girl

Clearance is focused on maintainability of the app's authentication code:

- Include comprehensive Shoulda and Factory Girl tests in the app's test suite
- Encapsulate authentication logic in modules which are included in
  controllers, models, and tests

This approach keeps the Rails application's code clean
and alerts the developer if the authentication code ever breaks.

Due to the work we've been doing to make Shoulda test framework-agnostic,
you will be able to use RSpec in the 0.5.0 release of Clearance.

Test::Unit and [Cucumber]
features are also supported:

[Cucumber]: http://github.com/aslakhellesoy/cucumber

```
script/generate clearance
script/generate clearance_features
```

## Conventions

To keep our approach simple, we made a series of design decisions:

- User model required
- User model uses [`attr_accessible`]
- Authenticate by email and password
- Vocabulary restricted to a trinity: "sign up", "sign in", "sign out"

[`attr_accessible`]: http://api.rubyonrails.org/classes/ActiveRecord/Base.html#M001981

## Beyond

Clearance does not try to be a Swiss Army knife but it does have some
hooks if you want admin roles,
sign up and sign in by username in addition to email,
or something else.

Please report bugs and request features on [GitHub Issues].

[GitHub Issues]: https://github.com/thoughtbot/clearance/issues
