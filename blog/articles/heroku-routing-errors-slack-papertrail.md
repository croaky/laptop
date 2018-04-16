# Alerts for Heroku Routing Errors

Most errors in a web application can be sent to a third-party service
such as [Sentry](https://sentry.io/),
with its errors grouped by type and by deploy.

On Heroku,
an important class of errors
never reach these services
because they don't occur in the application's processes,
they occur in the routing layer.

This article details a technique for surfacing these errors.

## Heroku Routing Errors

You may have seen
[Heroku Platform Error Codes][codes] in your logs:

* `H12 - Request Timeout`
* `H15 - Idle connection`
* `H18 - Request Interrupted`

These can be caused by many different factors ranging from
misconfigured web server concurrency
to slow clients (mobile phones on weak cell connections).

Before we can tune our app,
we need to first know these errors are occurring.

The bad news is we can't use our usual error tracking systems.
The good news is that Heroku
reliably includes the text `status=503` in the logs for these errors.

[codes]: https://devcenter.heroku.com/articles/error-codes

## Papertrail

[Papertrail] is a logger with a Heroku add-on.

[Papertrail]: https://devcenter.heroku.com/articles/papertrail

Add and open it:

```bash
heroku addons:add papertrail
heroku addons:open papertrail
```

* Search for `status=503` and click "Save Search".
* Give it a name and click "Save & Setup an Alert".
* Click "Slack".
* Command-click "new Papertrail integration" to open Slack in a new browser tab.
* Select your [Slack] channel for the Papertrail integration.
* Click "Copy URL" to get the webhook URL.
* Paste it back in the Papertrail add-on.
* Click "Create Alert".

[Slack]: https://slack.com

## Slack

Going forward,
you'll receive alerts for any Heroku routing errors
in your project's Slack channel.

Each log entry has a `request_id` that you can copy
and paste into Papertrail to see the contextual requests
before and after the 503.

Happy bug hunting.
