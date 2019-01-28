# Innovation

* [Jobs to be Done](#jobs-to-be-done)
* [Building Blocks](#building-blocks)
* [Other Countries](#other-countries)
* [Lessons Learned](#lessons-learned)

## Jobs to be Done

Examples of evolutionary change in the payments industry are:

* card networks moving from magnetic stripe to EMV chip cards
* PCI-DSS data security standards
* defining acceptance rules in non-face-to-face environments

Revolutionary change often occurs in "innovator's dilemma" fashion.
The new entrant begins by serving customers
that are not being served by industry incumbents.

The job to be done for payments is
to provide an exchange of value from buyer to seller.
The goal is a solution that is unencumbered with excess features
and can deliver a convenient experience.

I can pay for dinner at a restaurant with cash or a credit card.
Maybe the rewards I get on the card motivate me to use it.

When I buy something online, I can no longer use cash.
PayPal or Apple Pay enable me to use a card without entering card details.

The job to be done that issuers and acquirers hire payments networks for are:
* provide system and rules to facilitate exchange value
* ensure widespread acceptance
* manage integrity of network to minimize risk

PayPal identified small sellers on eBay were not well served.
The job they needed done was to accept payments from buyers
but traditional merchant card acquirers would not underwrite them.

Square identified pain in small merchants to accept in-person card payments.
They developed smartphone software
and card reader hardware to attach to the phone's headphone jack.

Three steps to transfer value from sender to receiver:

```
initiate payment -> fund payment (by sender) -> settle payment (with receiver)
```

Many innovations in payments focus on the initiation step
while not attempting to change the other two steps.
Contactless card transactions use different technology to read the card
but the way the transaction is funded and completed is unchanged.
PayPal used email addresses and passwords to replace
16-digit card numbers and expiration dates
but the rest of their transactions rode the card network rails.

It is much harder to gain adoption when both sender and receiver
are required to change. Gift cards and the Starbucks card are examples of
closed loop systems' ability to grow quickly.
Square Register was adopted by merchants but
Square Wallet was not adopted by consumers.

## Building Blocks

Innovations emerge when the right building blocks are combined
to address the most important jobs to be done.
A building block can be a new technology
or a new business model
(perhaps enabled by regulations, legislation, or network rule changes).

All modern payments systems
rely on computers and communications networks to operate.
Even cash uses anti-counterfeit technology and ATMs.

Some building blocks include the following.

APIs: API architectures enable new services to be constructed in ways that
ensure the integrity of the solution. They provide a platform upon which
young companies can build.

Open source software: Allow young companies to compress their development
cycles to rapidly implement their ideas.

Virtual currencies: New forms of cryptography-based currencies,
such as Bitcoin, have potential for globally usable currencies that might
augment today's approach to cross-border payments based upon a network of
correspondent banking relationships.

Blockchain: New shared database structure to improve efficiency in certain
financial services use cases.

Decentralized exchanges: Create peer-to-peer marketplaces to enable trading
without a central authority.

Invisible payments: Uber removes payment interaction by handling it
automatically at the end of a ride. The payment still happens but consumer
need not worry about it at destination and can get out of the car.

Marketplace payments: Uber, Airbnb, and others operate marketplaces
facilitating commerce from ride sharing to room rentals and more. Traditional
payments aren't always appropriate for these businesses. New entrants like
WePay have emerged to focus on them.

## Other Countries

Person-to-person systems such as M-Pesa in Kenya
address market requirements in a new way that wouldn't work in the U.S.
India's government focused on biometric authentication for all citizens,
which adds an important foundation layer for accelerating financial inclusion.

## Lessons Learned

The most important factors for innovating in payments are:

1. Solve chicken-and-egg problem: Provide compelling benefits for both sender
   and receiver. Have enough merchants on board to interest consumers, and
   enough merchants on board to interest consumers.
2. Get economic model right: Are charges visible? What are the risks and how are
   they priced? What are the customer acquisition costs?
3. Understand how to operate at scale: At the beginning, establish a reputation
   for trust, integrity, and reliability.
4. Understand regulatory requirements: Regulations may apply at national or
   lower (state) levels. Regulatory changes are an ongoing challenge. Each
   market must be considered uniquely and compliance addressed appropriately in
   each country.
