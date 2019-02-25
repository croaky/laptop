# North Star Metric

It is difficult to prioritize product and growth work.

Should we write a new feature?
Remove a feature?
Fix a bug?
Design a user interface?
Remove a step in the activation funnel?
Write a blog post?
Offer an e-book for a lead nurturing campaign?
Change pricing?
Hire a customer support person?

The [North Star] has been used for navigation
since Late Antiquity.
Applying it as a metaphor
to [startups],
we can define a North Star metric by
answering the question:

[North Star]: https://en.wikipedia.org/wiki/Pole_star#Northern_pole_star_.28North_Star.29
[startups]: http://www.paulgraham.com/growth.html

> How many people are getting authentic value from our product?

We say "authentic" value
to avoid vanity metrics
such as pageviews and sessions.

We don't use the terms
Daily Active Users (DAU) or
Monthly Active Users (MAU).
The North Star metaphor
reminds us to
use the metric
as our guide.
The moment when a user gets authentic value
may not always be when the user acts.

## Example North Star metric

An organization exists to serve [a mission][lec01].
A product exists to serve [a job to be done][jtbd].

[lec01]: http://startupclass.samaltman.com/courses/lec01/
[jtbd]: https://www.youtube.com/watch?v=f84LymEs67Y

For example,
thoughtbot's mission is to create better software.
We believe a job to be done
to create better software is
to keep a project's code in a consistent style.

[Hound] serves that job to be done
by reviewing GitHub pull requests
for style violations.

[Hound]: https://houndci.com

The moment Hound reviews
is called a "build."
It is the moment
the team gets authentic value
because the product helps them
keep their code
in a consistent style.
It is the moment
the product's job is done.

Hound's North Star metric is therefore:

> Teams with builds per week

## How to calculate it with SQL

We've often calculated the North Star metric using our application's SQL
database, hosted by [Heroku Postgres]. We run a SQL query on
our production database's "follower" (read-only slave) using [Dataclips]:

[Heroku Postgres]: https://www.heroku.com/postgres
[Dataclips]: https://devcenter.heroku.com/articles/dataclips

```sql
SELECT
  week,
  teams,
  (
    teams::float /
    lag(teams) OVER (ORDER BY week) - 1
  ) growth
FROM (
  SELECT
    date_trunc('week', builds.created_at) AS week,
    count(DISTINCT repos.id) AS teams
  FROM
    repos
    INNER JOIN builds ON builds.repo_id = repos.id
  WHERE repos.full_github_name NOT LIKE 'thoughtbot%'
    AND builds.created_at >= current_date - interval '14 weeks'
  GROUP BY week
) AS _;
```

The subquery aggregates our `builds` data into `week`s
using the `date_trunc` function and `GROUP BY` statement.
Within those `weeks`,
we `count` the `DISTINCT` GitHub repositories
and alias them as `teams`.

The `WHERE` clause filters the results
in any appropriate ways for the particular product.
We usually remove employees of
the product's company
and restrict the time window
to the previous quarter,
including this week in progress.

We have to be careful in the `WHERE` clause,
understanding the domain and code
enough to know whether the state of the data
we are querying now
represents a good state of the data
for the time period.

The outer query `lag`s each week's `teams` `OVER` its previous `week`
to calculate `growth`.
`lag()` is a [window function] that
compares rows of `teams` by an offset of `1`.

[window function]: https://thoughtbot.com/blog/postgres-window-functions

The result set looks like this:

|`week`|`teams`|`growth`|
|------|-------|--------|
|2014-09-22 00:00:00|114|N/A|
|2014-09-29 00:00:00|170|0.491228070175439|
|2014-10-06 00:00:00|197|0.158823529411765|
|2014-10-13 00:00:00|186|-0.0558375634517766|
|2014-10-20 00:00:00|198|0.064516129032258|
|2014-10-27 00:00:00|213|0.0757575757575757|
|2014-11-03 00:00:00|205|-0.0375586854460094|
|2014-11-10 00:00:00|230|0.121951219512195|
|2014-11-17 00:00:00|252|0.0956521739130434|
|2014-11-24 00:00:00|255|0.0119047619047619|
|2014-12-01 00:00:00|269|0.0549019607843138|
|2014-12-08 00:00:00|266|-0.0111524163568774|
|2014-12-15 00:00:00|213|-0.199330827067669|

## Growth rate

It is necessary to calculate
both absolute numbers
and growth rate
in order to completely understand
the product's current health.
We want to know Hound
currently has "266 teams with builds per week",
and is growing at "9% per week"
(the average of the trailing quarter,
excluding the current week).

[Paul Graham has written][startups] that
Y Combinator startups should grow
by 7% per week:

> When I first meet founders and ask what their growth rate is, sometimes they
> tell me "we get about a hundred new customers a month." That's not a rate.
> What matters is not the absolute number of new customers, but the ratio of
> new customers to existing ones. If you're really getting a constant number of
> new customers every month, you're in trouble, because that means your growth
> rate is decreasing.

He also identifies
our most-common follow-up question
after learning
the current North Star value
and growth rate:

> How many new versus retained users?

## New versus retained users

A second Dataclip calculates retained users:

```sql
SELECT
  date_trunc('week', builds.created_at) AS week,
  count(DISTINCT repos.id) AS retained_teams
FROM
  repos
  INNER JOIN builds ON builds.repo_id = repos.id
WHERE repos.full_github_name NOT LIKE 'thoughtbot%'
  AND builds.created_at >= current_date - interval '14 weeks'
  AND repos.created_at < date_trunc('week', builds.created_at)
GROUP BY week;
```

It is almost exactly the same
as the North Star's subquery
except for the `WHERE` clause's
`AND repos.created_at < date_trunc('week', builds.created_at)`,
which filters the data
to include only builds
from repos that were created
prior to the current week.

## Visualizing the data

We can use
Heroku Dataclips' CSV export
and Google Spreadsheets' [`IMPORTDATA`] function
to get a live import
in Google Spreadsheets:

[`IMPORTDATA`]: https://support.google.com/docs/answer/3093335?hl=en

```
= IMPORTDATA("https://dataclips.heroku.com/abc123.csv")
```

Which lets us chart the data
and make other calculations,
such as averaging the growth rate:

![Hound's growth Google Spreadsheet chart][chart]

[chart]: images/hound-growth-chart.png

The new versus retained teams bottom chart
is generated
by importing the second Dataclip
into a second Google Spreadsheet tab.
On that tab,
we calculate new teams
by subtracting the retained teams
from the total teams in the first Dataclip.

The "Goals" section
is calculated by multiplying
last week's
total teams,
retained teams,
and new teams
by 1.07 (a 7% growth rate).

The "Current" section
is calculated by dividing
this week's
total teams,
retained teams,
and new teams
by their corresponding goals.

## Data generates the necessary questions

The bottom chart
and our current progress
toward our goals
helps us make decisions about
whether to focus on
customer acquisition (marketing)
or customer retention (product).

The data is telling us
that retention is good
but acquisition is not.

The guidance from our North Star metric
causes us to ask questions such as
"which customer acquisition channels are working the best?", or
"do we have an awareness problem or an activation problem?"

Compare the Hound chart to another product's chart:

![Anonymous growth chart][anon]

[anon]: images/anonymous-growth-chart.png

In this example,
the data is telling us
that we're still
making something people want,
not yet ready for
marketing something people want.

## Prioritizing work by answering the questions

The questions lead us to look deeper into our data
in places such as
[Mixpanel funnels],
which helps reveal where in the product
people are getting blocked.

[Mixpanel funnels]: https://mixpanel.com/funnels/

Here's Hound's activation funnel in Mixpanel:

![Hound's Mixpanel funnel](images/hound-funnel.png)

While both steps could be improved,
it seems more likely that
improving the first step
would result in a bigger improvement
of our North Star:

> Teams with builds per week

Numbers identify the "what."
Our team identifies the "why."

To answer "why?",
we can critique [the current home page][hound]
for ways to improve
the user interface design.
For example,
we might want to change
the call to action
from "Sign in with GitHub"
to "Add Hound to your GitHub repo"
or some other copy text.

[hound]: https://houndci.com

Another way to answer "why?"
is to look for qualitative data
to compare to the quantitative data.
We often use
[Intercom for user research][intercom].

[intercom]: https://www.intercom.io/customer-feedback

In our conversations with users,
we may discover that they are
unhappy with the permissions we require
in the [GitHub OAuth] step of the sign up process.
That may lead us to change
the OAuth permissions,
removing functionality
which relies on the more aggressive permissions.

[GitHub OAuth]: https://developer.github.com/guides/basics-of-authentication/

## Design an experiment, instrument, implement, observe

We now have ideas
for changes to make.
In this example,
the changes are to the product,
but our process
could have as easily
led us to make changes to our marketing.

The product changes are
only one part
of the design of the [growth experiment].
We also need to define
how we will know if the changes are successful.

[growth experiment]: http://www.slideshare.net/500startups/02-brian-balfour-hub-spot-final

Changing the CTA text should
improve the conversion rate of
from "Viewed Home Page"
to a new "Clicked to Authenticate" event
in the funnel.

Requiring fewer GitHub permissions should
improve the conversion rate of
from "Clicked to Authenticate"
to "Signed Up."
That would represent
the percent of users
who have successfully
authenticated with GitHub.

As sometimes happens in these iterations,
we need to instrument the app
with a more granular event.
Then, we can compare the changes
by A/B testing.
Or, we could
deploy the instrumentation
and gather baseline data for a period of time
before deploying changes.

After we feel good about
our conversion rates,
we might turn our attention
away from product work,
toward marketing work such as
[prioritizing customer acquisition channels][bullseye].

[bullseye]: http://tractionbook.com/

## Learn more

Once we begin looking at the North Star metric
on a daily and weekly basis,
we've given ourselves an organizing mechanism
for deciding where to focus our time.

For more about North Star metrics,
watch talks from [Alex Schultz] and [Josh Elman].

[Alex Schultz]: http://startupclass.samaltman.com/courses/lec06/
[Josh Elman]: http://www.slideshare.net/500startups/01-josh-elman-greylock-partners-final
