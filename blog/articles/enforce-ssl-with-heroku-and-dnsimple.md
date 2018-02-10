# Enforce SSL with Heroku and DNSimple

Heroku and DNSimple have simplified the previously intimidating SSL certificate
setup process. The following steps should take us about 15 minutes.

## Buy the SSL certification from DNSimple

Buy a [wildcard certificate from
DNSimple](https://dnsimple.com/ssl-certificate). The wildcard (`*`) lets us use
the same certificate on staging, production, and any other future subdomains
(`api`, etc.).

## Prepare the SSL certificate

Follow [the wildcard certificate
instructions](https://devcenter.heroku.com/articles/ssl-certificate-dnsimple#wildcard-domain)
to get `.pem`, `.crt`, and `.key` files prepared.

Follow [these
instructions](https://devcenter.heroku.com/articles/ssl-endpoint#provision-the-add-on)
to complete `.key` preparation, provision the SSL addon from Heroku, and add the
certificate to Heroku:

```
heroku certs:add server.crt server.key
```

Replace it with:

```
heroku certs:add *.{pem,crt,key}
```

Otherwise, we might see an error like:

```
Updating SSL Endpoint myapp.herokussl.com for [heroku-app]... failed
  !    Internal server error.
```

## Get SSL endpoint from Heroku

Run:

```
heroku certs
```

This provides us the correct end point for the SSL enabled domain. This is a
domain that looks like `tokyo-2121.herokussl.com`.

## Add Heroku SSL endpoint to DNSimple

Next, go to our DNSimple dashboard and update/add the CNAME record for the SSL
enabled domain to point to (e.g.) `tokyo-2121.herokussl.com`.

## Prepare Rails app

Make a one-line configuration change in our staging and production environment
config files within our Rails app:

```ruby
# config/environments/{staging,production}.rb
config.force_ssl = true
```

Deploy that change.

Now, if users type <http://ourdomain.com>, they should be redirected to
<https://www.ourdomain.com> and our browser's URL bar should display its
appropriate indicator (perhaps a green lock) declaring the SSL certificate is
valid.
