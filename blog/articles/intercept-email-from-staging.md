# Intercept Email from Staging

Intercept email from the staging environment of a Rails app
and deliver it to a group email address
using [`croaky/recipient_interceptor`][recipient_interceptor].
This lets the product team preview emails
without accidentally delivering staging email to production customers.

[recipient_interceptor]: https://github.com/croaky/recipient_interceptor

In Gemfile:

```ruby
gem "recipient_interceptor"
```

In config/environments/production.rb:

```ruby
My::Application.configure do
  config.action_mailer.default_url_options = { host: ENV.fetch("HOST") }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address: "smtp.sendgrid.net",
    authentication: :plain,
    domain: "heroku.com",
    password: ENV.fetch("SENDGRID_PASSWORD"),
    port: "587",
    user_name: ENV.fetch("SENDGRID_USERNAME")
  }
end

if ENV.has_key?("EMAIL_RECIPIENTS")
  Mail.register_interceptor(
    RecipientInterceptor.new(ENV.fetch("EMAIL_RECIPIENTS"))
  )
end
```

Use the `EMAIL_RECIPIENTS` environment variable
to update the list of email addresses that should receive staging emails.

For example:

```
heroku config:add EMAIL_RECIPIENTS="staging@example.com"
```
