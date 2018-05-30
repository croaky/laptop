# Payments Systems in the U.S.

These notes were written while reading
[Payments Systems in the U.S.][source]
as a method to aim comprehension.

[source]: https://amzn.to/2kCpW5C

* [Open Loops and Closed Loops][loops]
* [Domains of Payment][domains]
* [Push and Pull][push]
* [Settlement][settle]
* [Rules][rules]
* [Regulation][regulation]

[loops]: #open-loops-and-closed-loops
[domains]: #domains-of-payment
[push]: #push-and-pull
[settle]: #settlement
[rules]: #rules
[regulation]: #regulation

## Open Loops and Closed Loops

Most electronic payments systems,
both paper-based and electronic
(cards, ACH, wire transfers, check images)
operate on an "open loop" model.

```
end party <-> bank <-> payments system <-> bank <-> end party
```

The advantage of the open loop structure
is it allows a payments system to scale rapidly.
As intermediaries join the payments system,
all their end party customers
are accessible to other intermediaries in the payments system.

In an open loop payments system,
the network defines the operating rules
to its participating banks
who then must ensure compliance by their end parties,
creating a chain of liability.

Network rules pass liability with the transaction.
Each party warrants compliance to the next.
Banks pass on liability to their customers.

```
end party <-> end-user-agreements <-> bank <-> network
bank <-> network operating rules <-> bank
bank <-> end-user-agreements <-> end party
```

A "closed loop" payments system
operates without intermediaries.
The end parties have a direct relationship with the payments system.

The original American Express and Discover systems,
and proprietary card systems
(a Macy's credit card accepted only at Macy's)
are examples of closed loop systems.

Most payments services providers operate as closed loop systems,
although some may access open loop systems
for transaction funding or delivery.

The advantage of closed loop systems is simplicity.
One entity sets all the rules
and has a direct relationship with the end parties.
It can act more quickly and more flexibly
than the distributed open loop systems,
which must propagate change throughout the system’s intermediary layers.

The disadvantage of closed loop systems
is that they are more difficult to grow than open loop systems;
the payments system must sign up each end party individually.

## Domains of Payment

There are five core payments systems in the United States:

* Cash
* The checking system
* The card systems (charge, credit, debit and prepaid cards)
* The ACH (Automated Clearing House) system
* The wire transfer systems

There are many other ways of making payments,
including online banking/bill payment and
email and mobile phone payments services.

Almost all of these methods rely on
one or more of the core payments systems
to actually transfer value between parties,
using them for funding and completion steps.

The United States is in the process,
along with many other countries,
of instituting a new "sixth rail" payments system:
the "immediate funds transfer" or "faster payments" system.

| System       | Count | Amount | Avg. Value |
| ---          | ---   | ---    | ---        |
| Debit Cards  | 74B   | $2.3T  | $31        |
| Credit Cards | 30B   | $2.8T  | $92        |
| ACH          | 24B   | $41.7B | $1,737     |
| Checks       | 14B   | $21.5B | $1,566     |
| Cash         | 67B   | $1.4B  | $21        |

Wire transfers are excluded.
If wire transfers had been included,
they would represent <1% of the total count
but 93% of the total amount
because of the high-value financial market transactions that use them.

Payments are used for multiple purposes:

* Point of Sale (POS).
  Payments made at the physical point of sale.
  Includes store and restaurant payments,
  but also unattended environments such as vending machines and transit kiosks.
  POS payments are sometimes referred to as proximity payments.
* Remote commerce.
  Payments made for purchases where the buyer is remote from the seller.
  This includes online and mobile purchasing,
  as well as mail-order or telephone-order buying.
  Key segments are e-retailing, online travel and entertainment,
  digital subscriptions, and digital content.
* Bill payment.
  Payments made by individuals or businesses based on receipt of a bill.
  This domain includes utilities, insurance, and services
  (personal or business) that are paid on a periodic, recurring basis.
* P2P payment.
  Person-to-person payments.
  Includes domestic payments among friends and families,
  but also cross-border remittances
  (e.g., migrant workers sending money to relatives in home countries),
  and account-to-account transfers by individuals
  (referred to as "A2A" or, sometimes, "me to me" payments).
* B2B payment.
  Business-to-business payments.
  Includes payments from buyer to supplier,
  but also intracompany payments and financial market payments
  (bank-to-bank payments, securities purchases, foreign exchange transactions)
  For the purposes of this framework,
  governments, non-profits, and other enterprises are included as businesses.
* Income payment.
  Payments to individuals for salary, benefits, rebates,
  and expense reimbursements.

## Push and Pull

When End Party A is sending money to End Party B,
it is considered a push payment.
Wire transfers and ACH direct deposit of payroll are push payments.

```
end party a -> bank -> payments system -> bank -> end party b
```

When End Party A collects money from End Party B,
it is considered a pull payment.
Checks, cards, and ACH debit transactions are pull payments.

```
end party a <- bank <- payments system <- bank <- end party b
```

Push payments are much less risky than pull payments.
In a push payment,
the party who has funds is sending the money,
so there is essentially no risk of NSF (non-sufficient funds).
Push payments can't bounce.

In a push payments system,
the transaction is initiated by the sender’s bank,
which knows that its end party has the money.
Other types of fraud are still possible.

"Pull transactions depend on the payer (End Party B)
having authorized the sender of the message to effect the transaction.
A signed check presented to a merchant,
or a card swipe with signature or PIN,
are examples of such an authorization.

Card networks are pull payment networks.
Card payments don't bounce
but this doesn't mean that they are push transactions.
They are guaranteed pull transactions.

The card networks accomplished this by adding a separate message flow,
called the authorization,
that runs through the network before the pull payment transaction is submitted.

This authorization transaction asks:

> Are there sufficient funds,
> or available credit balances,
> to pay this transaction?

If so, the pull transaction is submitted.
Card network rules specify that merchants receiving this yes reply
are covered for both insufficient funds and fraud risks.

## Settlement

Settlement in an open loop system refers to
the process by which the intermediaries
actually receive or send funds to each other.

The settlement function in an open loop system
can be done on either a net or a gross settlement basis.

In a net settlement system,
the net obligations of participating intermediaries
are calculated by the payment system
on a periodic basis (typically daily).

At the end of the day, a participating intermediary
is given a net settlement total and instructed either
(a) to fund a settlement account with that amount,
should it be in a net debit position, or
(b) that there are funds available to draw on in its settlement account,
should it be in a net credit position.

Checking, card payments systems, and the ACH are all net settlement systems
in the United States.
Settlement of checks and ACH,
when handled through a Federal Reserve bank,
is done on a batch basis:
a bank's account at a Federal Reserve Bank
is periodically credited or debited
with total amounts from a batch of transactions which have been processed.

In a gross settlement system,
each transaction settles as it is processed.
With the Fedwire system,
a transaction is effected
when the sending bank’s account at a Federal Reserve Bank
is debited and the receiving bank’s account at a Federal Reserve Bank
is credited.

No end-of-day settlement process is necessary in a gross settlement system.

In many countries around the world,
big changes are happening in how inter-bank net settlement is being done.
Settlement times are shortening:
instead of being done at the end of a business day,
the net settlement calculation
(and resulting funding or drawing of settlement account)
is done every few hours, or minutes,
or after a certain amount of transaction value has passed through the system.

Some systems are moving towards prefunding requirements of participating banks.
Rather than allowing banks to overdraft their settlement account,
they must already have sufficient funds in the account
to handle the transactions processed.

Finally,
some systems are moving towards allowing non-banks
to have direct access to core payments systems
and the settlement services supporting these systems.
The non-banks are institutions
that are chartered within a country
and permitted by national law to do certain types of payments.

## Rules

Most payments systems require either intermediaries (open loop systems)
or end parties (closed loop systems) to formally join the system.
The party joining the system is bound by the rules of the system.

Two core United States payments systems,
cash and checking,
operate on a virtual basis.
There is no formal payments system
that end parties or bank intermediaries join.

These virtual systems have no "capital B" brand (e.g. Mastercard),
and no central network that promotes their use.

Governmental and private rules regulates payments systems in the U.S.
Government rule is by law,
and by regulations issued by agencies of the government
to implement those laws.
In the United States,
the primary issuer of payments regulations is the Federal Reserve Board.

Private rules can either take the form of network rules,
or of contracts applying to a service used.
Private rules can be thought of as agreement-based.

Operating rules cover:

* Technical standards.
  Data formats, token (e.g., card) specifications,
  delivery and receipt capabilities, data security standards, etc.
* Processing standards.
  Time limits for submitting and returning transactions,
  requirements for posting to end party accounts, etc.
* Membership requirements.
  Types of institutions that can join, capital requirements, etc.
* Payment acceptance requirements.
  Constraints on the ability to selectively accept payments transactions.
* Exception processing and dispute resolution.
  Rights and requirements of intermediaries and end parties,
  often with respect to disputing or refusing a transaction.
* Fees.
  Processing and other charges paid to the payments system;
  interchange, if any, among the intermediaries.
* Brands and marks.
  Standards for use of the payments system brand.

Some open loop payments systems, Visa, Mastercard, and NACHA (for ACH),
make most of their operating rules publicly available on their websites.

Other payments systems,
such as CHIPS (for wire transfers) and most of the PIN debit card networks,
do not make their operating rules available to non-members.

## Regulation

Key laws and regulations:

* The Dodd-Frank Wall Street Reform and Consumer Protection Act of 2010,
  including the Durbin Amendment relating to U.S. debit card issuers/acquirers.
* Federal Reserve Bank Regulation E
  applies to consumer electronic transactions including
  debit cards, ATM withdrawals, and ACH transactions (but not credit cards).
  Regulation E establishes key consumer rights
  for repudiation and reversal of non-authorized transactions.
* Federal Reserve Bank Regulation CC
  Availability of Funds and Collection of Checks.

Other significant laws, regulations, and orders
fall under the general category of bank regulation.
These include regulation around money laundering, privacy, credit reporting,
and other issues relevant to payments.

Regulatory requirements around “Know Your Customer” (KYC)
are particularly important for banks and non-banks in the payments industry.
Provisions mandated by the Bank Secrecy Act and USA PATRIOT Act
require a variety of identity checking procedures
prior to opening a customer account.

State law and regulations by state banking authorities
apply mostly to non-bank providers of payments services,
and are generally referred to as money transmitter regulations.
They regulate sales and issuance of payments instruments,
as well as transmitting or receiving money.
Almost every state requires that money transmitters obtain a state license.
