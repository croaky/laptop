# Process Twitter Lead Cards with FormKeep

Twitter's [Lead Generation Cards][lead] are an advertising product
best used to... generate leads.
This article describes a technique for processing those leads
using [FormKeep].

[lead]: https://business.twitter.com/solutions/lead-generation-card
[FormKeep]: https://formkeep.com

## Pre-launch email list

We are in the pre-launch phase for [Rototo],
an iPhone and Android game we created in our Stockholm office
with help from Melissa and Connie in Boston.

A core part of our launch plan is to build up an email list
of people interested in playing the game when it is released.

[Rototo]: http://playroto.to

So, the pre-launch website looks like this:

[![](https://images.thoughtbot.com/rototo/pre-launch-form.png)][Rototo]

It is a [Middleman] site hosted using [GitHub Pages].
Since the site is static,
we are using FormKeep to capture email addresses.

[Middleman]: https://middlemanapp.com/
[GitHub Pages]: https://pages.github.com/

## Driving traffic

We now need to drive traffic to the website.
We're doing that in expected ways:

* Sharing the news and URL
  with our friends and family
  via email, Twitter, Facebook, etc.
* Googling "retro iOS"
  to find bloggers and journalists who are passionate about the topic,
  asking them if they want to play the game before it is released.
* Buying Facebook Ads to drive clicks to the site.

Twitter's Lead Cards and FormKeep allow us to
let our potential customers
skip the step of landing on the website
and submitting their email address.

## Create the Lead Card

1. Sign in to [Twitter Ads].
1. Click "Creatives > Cards".
1. Click "Create Lead Generation Card".

You'll see a screen like this:

[Twitter Ads]: https://ads.twitter.com

![](https://images.thoughtbot.com/formkeep/twitter-lead-cards/creative.png)

## Create the FormKeep form

1. Open a new browser tab.
1. Go to [FormKeep].
1. Create a form and give it a name.

You'll see a setup screen like this:

[FormKeep]: https://formkeep.com

![](https://images.thoughtbot.com/formkeep/twitter-lead-cards/setup.png)

At this point,
you would normally copy the HTML and paste it into your static landing page
to start collecting email addresses in your pre-launch campaign.
For the purpose of the Twitter card,
copy the URL in the `action` attribute of the `form` element.

## Use the URL in your Lead Card

Back on the "Create Lead Card" page,
click "Data settings (optional)".
Paste the FormKeep form's URL into the "Submit URL" field.
Select "POST" as the HTTP method.

![](https://images.thoughtbot.com/formkeep/twitter-lead-cards/twitter-post-data.png)

Save and continue.
The Twitter Ads platform will immediately test the setup:

![](https://images.thoughtbot.com/formkeep/twitter-lead-cards/success.png)

If there are any errors, they will show up here.
This screen shows a successful POST
and asks us to check our CRM or marketing automation system
to confirm it is set up correctly.

## Create Twitter ad campaign

Click "Campaigns > Reports by objective".
Click "Create new campaign > Leads on Twitter".
In the ad creative section,
you can compose promoted-only tweets
and select the Lead Card as their call to action:

![](https://images.thoughtbot.com/formkeep/twitter-lead-cards/create-campaign.png)

The rest of the "Create new campaign" form
contains targeting, budget, and schedule options
that are custom to your product.

## FormKeep collects, filters, and forwards via webhook

Over time, the FormKeep form will look something like this:

![](https://images.thoughtbot.com/formkeep/twitter-lead-cards/satisfying-result.png)

Submissions will come in both from the website pre-launch form
and from the Twitter Lead Generation Card.
The Twitter leads will contain a bit more information,
such as the user's Twitter handle,
but FormKeep handles the mix of data gracefully.

## Email autoresponders

For any sale,
it's a good idea to
follow up with leads within minutes.
For a lead added to a mailing list,
our goals are to reinforce the value proposition
and generate an asset in the person's inbox
for them to see, be reminded of, and hopefully share with others.

For Rototo,
we have a [FormKeep Zapier trigger][trigger] a [HubSpot] email
to autorespond to folks who sign up.
We remind them of the value proposition,
link to a few fun YouTube clips of Galaga, Space Invaders, Missile Command,
Defender, and other retro games to stimulate nostalgia and excitement,
and finish with a call to action to spread the word.

[trigger]: https://robots.thoughtbot.com/the-formkeep-zapier-trigger
[HubSpot]: https://hubspot.com

FormKeep works equally as well with MailChimp, other Zapier integrations,
or no email at all if you want to keep it simple with a CSV export later on.
