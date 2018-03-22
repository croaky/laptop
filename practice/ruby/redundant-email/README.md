# Redundant Email Service

This web service provides an API
that accepts a `POST` HTTP request to `/email`
with a JSON body
and delivers an email on the user's behalf.

The backend email service is redundant.
By default, it uses [Mailgun]
but can be switched to [SendGrid]
with a configuration change.

[Mailgun]: https://documentation.mailgun.com/en/latest/quickstart-sending.html
[SendGrid]: https://sendgrid.com/docs/API_Reference/Web_API_v3/Mail/index.html

## Use

Edit the `example.json`'s `to` field to be your email address.

Then, test the service hosted on Heroku:

```
curl -d "@example.json" -X POST https://redundant-email.herokuapp.com/email
```

## Contribute

Set up the project's dependencies:

```
./bin/setup
```

Run the specs:

```
rspec
```

Edit `.env` with your API keys.

Run the app:

```
ruby app.rb
```

Make requests against the app:

```
curl -d "@example.json" -X POST http://localhost:4567/email
```

## Switch backend email service

After `bin/setup`, using [Parity]:

```
production config:set EMAIL_SERVICE=sendgrid
```

Or:

```
production config:set EMAIL_SERVICE=mailgun
```

[Parity]: https://github.com/thoughtbot/parity
