# Redirect Apex Domain to WWW

Redirect apex domains (`statusok.com`) to a subdomain (`www`)
with [DNSimple] and [Netlify].

I created these two DNS records:

[DNSimple]: https://dnsimple.com
[Netlify]: https://www.netlify.com

```
ALIAS  statusok.com      statusok.netlify.com
CNAME  www.statusok.com  statusok.netlify.com
```

## www.statusok.com

When a user requests the subdomain `www.statusok.com`:

* her browser receives a `CNAME` to look up `statusok.netlify.com`
* her browser looks up `statusok.netlify.com`
* her browser receives an `A` record from Netlify's pool of available CDN nodes
  geographically closest to the end user

```
% dig www.statusok.com

;; ANSWER SECTION:
www.statusok.com.      CNAME  statusok.netlify.com.
statusok.netlify.com.  A      104.198.6.175

;; AUTHORITY SECTION:
netlify.com.           NS     ns1.p04.nsone.net.
netlify.com.           NS     ns4.p04.nsone.net.
netlify.com.           NS     ns2.p04.nsone.net.
netlify.com.           NS     ns3.p04.nsone.net.
netlify.com.           NS     s1.netlify.com.
```

If Netlify detects their main load balancer is slow or unresponsive
(for example, if under a DDoS attack),
they [route around that on the DNS level][www].

[www]: https://www.netlify.com/blog/2017/02/28/to-www-or-not-www/

## statusok.com

When a user requests the apex domain `statusok.com`:

* DNSimple's [`ALIAS`][ALIAS] record
  sends a `CNAME` look up to Netlify at `statusok.netlify.com`
* her browser receives an A record
  from Netlify's pool of available CDN nodes
  geographically closest to the end user

[ALIAS]: https://support.dnsimple.com/articles/alias-record/

```
% dig statusok.com

;; ANSWER SECTION:
statusok.com.  A   104.198.6.175

;; AUTHORITY SECTION:
statusok.com.  NS  ns4.dnsimple.com.
statusok.com.  NS  ns3.dnsimple.com.
statusok.com.  NS  ns2.dnsimple.com.
statusok.com.  NS  ns1.dnsimple.com.
```

Netlify can still route around outages.
End users save an extra DNS lookup.

An `ALIAS` record is better for this case
than a `A` record or `URL` record on DNSimple.

An `A` record doesn't let Netlify insert traffic direction between
the end user's DNS lookup and Netlify infrastructure.
So, they can't route users to the closest CDN node or around an outage.

DNSimple's `URL` record is a 301 redirect,
[which doesn't support https][301].
`http://statusok.com` to `https://www.statusok.com` would work
but `https://statusok.com` would not.

[301]: https://support.dnsimple.com/articles/redirector-https/
