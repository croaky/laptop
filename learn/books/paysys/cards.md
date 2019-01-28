# Cards

* [Overview](#overview)
* [Card Types](#card-types)
* [Acceptance Environments](#acceptance-environments)
* [Roles](#roles)
* [Enabling Technology and Standards](#enabling-technology-and-standards)
* [Processing](#processing)
* [Use](#use)
* [Regulation](#regulation)
* [Interchange](#interchange)
* [Issuance](#issuance)
* [Economics](#economics)
* [Acquiring](#acquiring)
* [Payment Facilitators](#payment-facilitators)
* [Risk](#risk)

## Overview

The cards payments system:

* has "pull" payments with authorization
* is owned by a private network of companies
* is governed by U.S. law and Federal Reserve Bank regulation
* economics are interchange (acquirers to issuers),
  assessments (issuers and acquirers to network),
  and currency conversion
* processes electronically
* manages risk by network definition, augmented by processors and end parties

The cards payments systems are at the heart of consumer commerce,
facilitating trillions of dollars of spending each year.
They are extremely standardized, interoperable,
and profitable for credit card issuers and others in value chain.

Bank of America rolled out its BankAmericard product in California in the 1950s
and licensed it to banks outside of California by the mid-1960s.
forming a company, BankAmerica Service Corporation,
to manage the U.S. card program.
In the mid-1970s,
a similar organization was formed to manage the international card program.
Soon after, the U.S. and international companies combined to become Visa.

Separately, another group of California banks formed a competing organization
called the Interbank Card Association and rolled out its MasterCharge card.
In the late 1970s, it renamed itself and its product to Mastercard.

The early work of these companies established
associations of member financial institutions with open membership,
interchange fees,
brand control,
fraud reporting,
and arbitration processes to settle disputes.

The open loop networks enabled a profitable consumer lending business
for card-issuing banks. New relationships could be established not of
a consumer opening a checking account but applying for a credit card.

Card issuing banks serve consumers.
Acquiring banks serve merchants.

In the late 1960s, banks issued automated teller machine (ATM) cards
to checking account customers to enable them to withdraw cash.
Usage required authenticating with a personal identification number (PIN).

Banks began sharing ATM networks.
Banks wanted cost reduction (saving on teller expenses).

In the late 1980s and 1990s,
ATM networks went through a series of mergers moving to non-bank ownership.
Interlink, STAR, and NYCE were some of the largest national networks.
Visa eventually acquired Interlink.
In 2004, First Data Corporation bought STAR and
Metavante bought NYCE.

ATM cards began being accepted at point of sale.
Merchants wanted to eliminate checks with their "bounce" risk.
Merchants had to deploy new acceptance equipment to read
the card's magnetic stripe and to securely accept the cardholder's PIN.

In the mid-1980s, credit cards and debit cards could be accepted by merchants
at point of sale. This led Visa and Mastercard to develop debit products
for retail banks to ride over their credit card network "rails" rather
than over of the shared ATM/PIN debit networks.

In 2006, Mastercard IPO'ed.
In 2008, Visa IPO'ed (the largest in US history to that point).

## Card Types

Charge cards are non-revolving: the cardholder pays in full,
at the end of the billing period, for all charges incurred.

Credit cards provide access to a revolving, unsecured line of credit.
The cardholder can pay the balance in full
or over a period allowed by the card issuer.

Signature debit cards access funds on deposit in cardholder's checking account
authenticated by comparing signature on card to receipt.
Transactions are carried over the Visa or Mastercard network
depending on bank issuer's choice of card brand.

PIN debit cards access funds on deposit in cardholder's checking account
authenticated by entering a PIN on a keypad.
Transactions are carried over the PIN or ATM networks.
They can be used to provide cash back to the consumer at point of sale.

The same physical card is typically used for PIN and signature debit.
The card issuer determines whether both authentication methods are supported.
On swipe, the merchant can look up the issuer's routing options
and determine whether to prompt for PIN or not.

Prior to the [Durbin Amendment](https://en.wikipedia.org/wiki/Durbin_amendment),
merchants often prompted for PIN
in order to route the transaction over the lower cost PIN debit network.

Prepaid cards access funds from a pre-funded account. Examples are gift cards
and typically operate over the Visa or Mastercard networks.

Although most debit cards in the U.S. use the signature or PIN debit networks
to access funds in a consumer's checking account,
it is possible to use the ACH network to accomplish nearly the same thing.

With ACH debit cards,
the merchant saves by paying no merchant discount fee
but is exposed to NSF risk.
The cards are governed by NACHA rules.

For many consumers,
debit cards win on convenience.
Consumers think "how do I spend the money in my bank account?"
and debit cards represent a fewer step (don't have to pay credit card balance).

## Acceptance Environments

Card-present (CP) transactions occur when the cardholder uses their card at a
terminal. Network rules usually protect the merchant from fraud risk.

Card-not-present (CNP) transactions occur when the cardholder is making a remote
purchase such as online or by phone. Network rules usually don't protect the
merchant from fraud risk.

## Roles

In an open-loop network,
an issuing bank serves the cardholder
and acquiring bank serves the merchant.
The card network sits in the middle,
managing transactions, rules, risk, and disputes.

In a closed-loop network,
a single card company performs the issuing, acquiring, and network functions.

Card issuing involves
soliciting new customers,
underwriting new customers,
furnishing each customer with a card,
authorizing and clearing transactions,
and providing statements.

Card acquiring involves
providing and servicing POS terminals and software,
processing card,
managing disputes,
and providing customer service.

## Enabling Technology and Standards

American Express first introduced the plastic credit card in the late 1950s.
The dimensions and other characteristics are now standardized as ISO 7810.

The card has defined data fields and locations,
both printed or embossed on the physical card
and encoded in the magnetic stripe on its back.

The key card data element is the Primary Account Number (PAN).
The first six digits are the Issuer Identification Number (IIN)
which identifies the card network and issuing bank.
The American Bankers Association acts as the registry for IINs.

Security codes are called CVV (Visa), CVC (Mastercard), or CIN (AmEx).
The code is encoded on the magnetic stripe
but not physically embossed or printed on the card.
They were added in the 1990s to help prevent fraud.

Card network rules and federal legislations require that
merchants truncate card number details from receipts
to reduce exposure of payment card credentials.

CVN2s are the three- or four-digit number printed on the signature panel
on the back (or, for AmEx, the front) of the card.
These are used as the "Card Security Code" for card-no-present transactions.

In most countries,
cards are migrating from magnetic stripe to chip technology.
These cards have both a magnetic stripe and chip.
Until universal chip reading infrastructure exists globally,
it's not yet possible for issuers to eliminate magnetic stripes.

Two chip standards exist.

The first chip standard is EMV.
They have physical contacts present on the face of thee card.
When inserted into an EMV-capable POS device,
contact is made with the chip to power up and perform processing.
EMV cards are typically used with PINs, referred to as "Chip-and-PIN".

European countries made early decisions to migrate to EMV
on concerns about counterfeit card fraud.

In the U.S., the calculation was that there wasn't enough fraud
to justify the costs of migrating.
That changed when Visa introduced rules where merchants who did not migrate
to new EMV devices became liable for fraud instead of the issuer.

The second chip standard is based on contactless RFID technology.
They were implemented for customer convenience, not fraud prevention.
Contactless acceptance devices are important to the deployment of
certain kinds of mobile payment based on near field communication (NFC)
such as Apple Pay and Android Pay.

## Processing

In the U.S., many point of sale terminals can read cards and pass data
to the acquirer (either acquiring bank itself or the bank's processor).
These may be freestanding devices
or software integrated into electronic cash registers (ECRs),
mobile tablets, or other devices.

Credit card and signature debit transactions (without PINs)
are routed through the acceptance grid twice:
once in real time for authorization
and again (typically at the end of the day) for clearing and settlement.

The card network processing hubs sit in the middle,
receiving transactions from acquirers and
sorting and switching them to issuers.
The major card networks have extensive redundancy and resiliency built in,
with impressive records for high availability.

Authorization is in real-time, with sub-second response times.
Clearing and settlement occurs in batch, typically at end of day.

## Use

Consumer credit, debit, and prepaid cards are used for
purchases at point of sale locations,
for online purchases,
to make bill payments,
and to obtain cash.

Business credit and charge cards are used for
travel and entertainment purchases
and to make and receive payments from suppliers and customers.

Both are used to make cross-border payments.

Average purchase amount is higher for credit cards than debit cards.
Debit cards are typically used for "everyday spend".
Credit cards are typically used for higher-value purchases, travel, etc.

Transaction volume is higher for debit cards than credit cards
and increasing at a faster rate.

## Regulation

The operating rules of open loop networks such as Visa and Mastercard
govern most aspects of card issuing, authorization, clearing, and acquiring.

The card company rules diverge in many ways
but converge in others where fraud prevention or standardization is important.

A well-known example is the PCI Standards Council
which provides the PCI-DSS data security requirements
for the protection of payment card data.
Visa, Mastercard, AmEx, and Discover are all involved in this organization.

Card networks publish semiannual calendars of upcoming rule changes
to give banks and their processors time for system upgrades.
The card networks have been criticized for
the accumulated complexity of their operating rules
and have recently tried to simplify.

The rules are publicly available to be inspected by regulators,
potential customers, and other interested parties.

U.S. federal laws include:

* 2009's Credit Card Accountability Responsibility and Disclosure (CARD) Act,
  focused on consumer protection regarding interest rate settling, billing,
  and notifications. It doesn't specify fee or rate maximums.
* 2010's Dodd-Frank Act containing the Durbin Amendment,
  focused on debit card interchange and network routing.
  It created the Consumer Financial Protection Bureau (CFPB),
  which maintains a database of credit card agreements from 300 issuers,
  conducts an annual survey of terms of credit card plans,
  and examines credit card marketing agreements.

## Interchange

Revenue models for card networks include
processing fees,
brand-use service fees on transactions,
and handling foreign exchange for cross-currency transactions.

Costs for card networks include
operating substantial transaction processing centers,
a global telecommunications infrastructure,
staff,
brand promotion,
and advertising.

Card networks define interchange in order to balance
the benefit received by the merchant and its acquiring bank
with the costs incurred by the card issuer.

* Guarantee. The card issuer guarantees the merchant is paid
  even if the cardholder fails to pay the card issuer.
* Funds. The merchant receives payment from the issuing bank
  via the card network before the issuing bank is paid by the cardholder.
* Operating expenses. The issuing bank has expenses in operating its
  authorization network, producing statements, handling customer service, etc.

Each card transaction involves two banks with interchange being a fee
that one bank pays to the other as compensation for some of its costs.
The network sets the fee.

For U.S. transactions, the merchant's acquiring bank pays the issuing bank.
(For U.S. ATM transactions, the card issuer pays the ATM deployer.)

The acquiring bank passes the interchange expense to its customer,
the merchant. Example fees on a $100 purchase are:

* Mastercard and Visa credit card: $1.75
* American Express card: N/A
* Regulated debit card: $0.25
* Exempt debit card: $0.51

Closed loop networks do not have interchange,
although the network assesses to the merchant a "merchant discount fee"
which is kept by the network
rather than distributed to a acquiring bank or issuing bank.

Interchange is controversial.
One perspective is interchange is a necessary balance in a two-sided market.
Another perspective is interchange is a form of price fixing
that does not allow the merchant to negotiate prices for a key service.

## Issuance

The credit card has been called
"the most profitable product in banking history".
Industry revenues are estimated at $100B annually
and credit card balances exceed $925B.

In the United States, credit card issuance enjoys:

* Near-universal acceptance. Most merchants accept credit cards.
* A saturated marketplace. More than 60% of Americans have an open credit card.
  Many Americans without access to credit have debit or prepaid cards.
* Multiple cards. Of Americans with credit cards, most have almost four cards.

The top ten U.S. credit card issuers
handled more than 80% of card purchase volume in 2015 including
JP Morgan Chase, Bank of America, Citibank, Capital One, and Wells Fargo.

Credit card issuers
choose which networks to use,
solicit new card holders,
issue cards,
compete for purchase volume by being "top of wallet",
manage fraud,
manage clearing and authorization,
manage statementing and customer service,
manage the cost of funds,
manage rewards.
and manage collections.

Credit card processors may do some or all of the tasks listed above.
The largest processors in the U.S. are First Data and TSYS.

In order to open a checking account for a customer and issue a debit card,
a bank must go through a "Know Your Customer" (KYC) process
mandated by the USA Patriot Act of 2001.

Debit card issuers
issue cards,
choose and manage the ATM and debit card networks,
manage fraud,
manage clearing and authorization,
and manage rewards.

Debit card processors may do some or all of the tasks listed above.
The largest processors in the U.S. are Interlink (Visa), STAR (First Data),
TSYS, Maestro (Mastercard), NYCE (FIS), Accel (Fiserv), and Pulse (Discover).

## Economics

"Revolving" credit cards are the basic credit card.
The cardholder can pay the balance in full each period (a "transactor")
or make partial payments over time (a "revolver").
Most cards allow the cardholder to avoid paying interest
as long as the balance is paid in full.

Transactors almost never pay interest charges.

Economics for the credit card industry are dominated by
interest earned on revolving loans to cardholders who are revolvers.

Banks earn revenue on credit cards from:

* Interest (~50%)
* Interchange (~20%)
* Fees (~10%)

Some banks market cards only to existing customers (e.g. checking account).
Others aggressively market to anyone.

All are vulnerable to changes in the economy.
The loss rate is usually around 5% but can be 10% or more during recession.

Debit cards are not a standalone product like a credit card.
They are a component of the checking account product.

Banks earn revenue on debit cards from:

* Interest on balance in checking account
* Interchange
* Routine monthly fees
* Exceptional fees (e.g. overdraft)

There is no technical reason why debit cards should "bounce" (overdraft)
because they are authorized at the time of transaction.
Banks allow it because it generates revenue :(.
There are minimal federal regulations protecting consumers from this practice.

Consumers have grown to expect rewards on their cards.
Because there isn't much interchange revenue on debit cards,
debit cards have less valuable rewards.

Acquirers earn revenue from
"interchange plus" (card network fee assessed to acquirer plus "x cents per
transaction plus y% of transaction value)

## Acquiring

From a merchant perspective,
the "acquirer" is the entity that sold the merchant their account
and with whom they deal with day-to-day.
It might be a bank, processor, gateway, or sales org.

From a card network's perspective,
the "acquirer" is the bank that belongs to the network
and has contractual liability for the actions of it clients.

The acquirer's roles may include:

* providing POS devices to accept cards
* "front-end processing" handling authorization message processing.
  This is real-time and fixed fee.
* "back-end processing" handling settlement and clearing in batch.
  The back-end processor applies interchange to transactions,
  handles chargebacks and disputes,
  and handles reporting. Fixed fee per transaction plus exception fees.
* acquiring bank. Every card network transaction must use an acquiring bank.
  Share of the discount fee.

New entrants such as Square have dramatically simplified merchant statements
and associated pricing and terms.

## Payment Facilitators

New card network operating rules allow a firm to act as a
"payment facilitator" to sign up and process payments for small merchants.
Examples are PayPal, Square, and Stripe.

Payment Facilitators are sometimes referred to as "aggregators"
because they aggregate many smaller merchants
to be processed by a single acquirer.

## Risk

Issuers take on credit risk when extending a line of credit to a new cardholder.
They control this risk via approval process
and periodic reviews of the account and behavior.

Card networks have recently eliminated the signature requirement
for many merchant category codes for purchases
such as purchases under $15 in unattended environments
or under $25 when attended.

Processing system intrusions have compromised millions of card accounts at once.
In addition to leading to fraudulent card usage,
these attacks are costly to issuers who need to handle public relations
and decide whether to re-issue cards on compromised accounts.

To help address the data breach issue, the card industry has tried to
reduce or eliminate the storage of card credentials.
These initiatives are called "tokenization" and involve aliases or proxies
of card numbers which have limited utility and even if compromised,
result in significantly lower levels of fraud loss.

Apple Pay was an early adopter of tokenization
and uses it to store a totally different card number on mobile device
than is on the cardholder's card.
