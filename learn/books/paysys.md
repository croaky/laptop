# Payments Systems in the U.S.

These notes were written while reading
[Payments Systems in the U.S.][source]
as a method to aim comprehension.

[source]: https://amzn.to/2kCpW5C

Overview:

* [Intro](#overview)
* [Open and Closed Loops](#open-and-closed-loops)
* [Domains of Payment](#domains-of-payment)
* [Push and Pull](#push-and-pull)
* [Settlement](#settlement)
* [Rules](#rules)
* [Regulation](#regulation)
* [Economic Models](#economic-models)
* [Interchange](#interchange)
* [Risk Management](#risk-management)
* [Thick and Thin](#thick-and-thin)
* [Comparing Systems](#comparing-payments-systems)
* [Cross-Border Payments](#cross-border-payments)
* [Other Countries](#other-countries)
* [Changing Networks](#changing-networks)

Checking:

* [Overview](#checking)
* [Clearing Houses](#clearing-houses)
* [Automation](#automation)
* [Roles](#roles)
* [Ownership](#ownership)
* [Volume and Trends](#volume-and-trends)
* [Economics and Products](#economics-and-products)

## Overview

A payment is a transfer of value
from one end party (the sender)
to another (the receiver).
The transfer of value is denominated in currency.

Most payments systems share these characteristics:

* Operate within a single country.
* Denominate in the currency of that country.
* Are subject to regulation by the government of that country.
* Enable multiple parties to transact.

### Open and Closed Loops

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

### Domains of Payment

There are five core payments systems in the United States:

* Cash
* The checking system
* The card systems (charge, credit, debit and prepaid cards)
* The ACH (Automated Clearing House) system
* The wire transfer systems

There are many other ways of making payments,
including online banking/bill payment and
email/mobile payments services.

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

### Push and Pull

When End Party A is sending money to End Party B,
it is considered a push payment.
Wire transfers, ACH direct deposit of payroll,
and [cryptocurrencies](https://bit.ly/2kCmZ51)
are push payments.

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
so there is essentially no risk of non-sufficient funds.
Push payments can't bounce.

In a push payments system,
the transaction is initiated by the sender’s bank,
which knows that its end party has the money.
Other types of fraud are still possible.

Pull transactions depend on the payer (End Party B)
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

### Settlement

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
inter-bank net settlement is changing.
Settlement times are shortening:
instead of being done at the end of a business day,
the net settlement calculation
(and resulting funding or drawing of settlement account)
is done every few hours, or minutes,
or after a certain amount of transaction value has passed through the system.

Some systems are moving towards pre-funding requirements of participating banks.
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

### Rules

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
  Data formats, token (e.g. card) specifications,
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

Some open loop payments systems such as Visa, Mastercard, and NACHA (for ACH)
make most of their operating rules publicly available on their websites.

Other payments systems,
such as CHIPS (for wire transfers) and most of the PIN debit card networks,
do not make their operating rules available to non-members.

### Regulation

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

Regulatory requirements around "Know Your Customer" (KYC)
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

### Economic Models

Banks, networks, and processors make money by
providing access to payment systems for end parties
(consumers, merchants, and enterprises) and
intermediaries (banks).
Merchants may provide payments services via gift cards.

Direct revenue comes from fees:
transaction fees, interest on loans, monthly maintenance fees,
and exception fees for overdraft, bounced checks, or late payments.

Indirect revenue comes from
net interest income on deposit balances, float, and interchange.

Providers who realize revenue related to the gross value of the payment
transaction ("amount") are more likely to have profitable businesses
than those who realize revenue on a fee-per-transaction basis ("click fee").

"Ad valorem" (percent of value) revenue
may be direct (fee calculated as % of amount, or interest rate on loan balance)
or indirect (value of deposit balances held at a bank, or float).

The cost of handling exception items (bounced checks, customer disputes)
is much higher than the cost of handling a standard transaction.
The efficiency which a provider manages exception processes
affects the overall economics of the product for that provider.

### Interchange

Interchange is used by some open loop systems,
particularly by card networks.

Interchange is a transfer of value from one intermediary in a transaction
to another intermediary in that transaction.

The payments system sets the interchange prices
but does not itself receive the value of the interchange.

Interchange creates an incentive for one side to participate
by having the other side reimburse some incurred costs.

U.S. wire transfer, ACH, and checking systems
have traditionally operated without interchange
but "same day ACH" have added an interchange component.

### Risk Management

All payments are subject to risk.
Three major forms are credit risk, fraud risk, and liquidity risk.

Credit risk. A cardholder may fail to repay their loan balance.
When a bank extends an overdraft rather than bouncing,
it incurs credit risk.

Fraud risk. Cash can be stolen. Consumer identity can be fraudulently
represented in checking, credit cards, debit cards, ACH, and wire transfers.
Non-sufficient funds risks exist for merchants using checking and ACH pull.

Liquidity risk. In open loops, end parties have financial liability to their
banks, banks have liability to the network, and the network has liability to
the banks. The network's exposure is "settlement risk". If a network member
goes out of business during the day while in a net debit position, the network
must pay the obligation of that member to the other members.

Secondary risks include operational risk, data security risk, reputation risk,
regulatory risk, and currency (exchange rate) risk.

Operational risk. One party fails to do something or does something in error.
Examples are missed deadlines, incorrectly formatted files, and jammed check
sorting machines.

Data security risk. End party data is exposed to fraudulent use.
Actions taken by card networks to create and enforce
PCI-DSS (Payment Card Industry Data Security Standards)
are an attempt to manage this issue. More recently,
the card industry has tokenized issuers to protect payment card credentials.

Reputation risk. End parties lose faith in the integrity of the system.
The loss of payment card data at merchants and processors damages reputation.

Regulatory risk. Unclear interpretation or application of private rules
or government regulation. In most cases, innovation outpaces regulation.

Currency risk. Taking a position on a guaranteed transaction
prior to the actual exchange rate being set or known.

### Thick and Thin

"Thick" payment networks have lots of money, enabling investment
in product definition, brand, risk management, and exception processing.
Examples are Visa, Mastercard, American Express, and PayPal.

"Thin" payment networks manage only minimal interoperability issues,
leaving product, brand, risk, and exception functions to intermediaries.
Examples are check clearing houses, ACH, and PIN debit networks.

Thick networks enable significant profits for its member banks.
Think networks exist to reduce costs, operating as an efficient utility.

### Comparing Systems

Payments systems compete with each other.
Providers have questions when deciding to support a new form of payment.
Users have questions when deciding to use a new form of payment.

* Open or closed loop?
* Push or pull?
* Net or gross settlement?
* Private or public?
* Private rules and/or law/regulations?
* Batch or real-time processing?
* Interchange or other fees?
* Branding?
* Guaranteed payment?
* Timing of funding?
* How are exceptions (fraud, disputes) handled?
* Thick or thin?

The authors believe:

* Risk pays
* "Ad valorem" fees are better than flat fees
* Cross-currency is lucrative
* Processing demands scale
* Businesses pay to be paid
* Banked customers don't pay to pay
* Unbanked customers pay to pay :(
* Exception processing is expensive
* Simplicity has economic value

### Cross-Border Payments

Cross-border payments occur when an end party in one country
pays an end party in another country.

Payment systems, by definition, operate on in-country basis:
only banks chartered or licensed to operate in a country
may join a payments system in that country.

Transferring money often requires two transactions
(one in the sending country and one in the receiving country)
even if the transaction is denominated in the same currency in both systems.

The global card networks bind together country-specific payments systems
to create the effect of a global payments system.
To an end party or even intermediary, it appears to be global.

In Europe, the SEPA (Single Euro Payments Area) payments systems
are an attempt to resolve a problem introduced with the euro:
a France-to-Germany (for example) euro payment had to be processed by
two payments systems: French and then German.
SEPA created a system that banks in both countries can belong to directly.

Two transactions must still be settled among banks.
The global financial services messaging service SWIFT plays a role
in carrying instructions about these payments from one bank to another.

Effecting a single transaction in two separate payments systems
creates complexity and confusion. The systems may have different schedules,
rules, and data formats. Hefty fees are common. Foreign exchange adds another
layer of complexity.

### Other Countries

A good place to learn about each country's payment systems
is the website of the central bank of that country.

The types of payment systems in each country is similar
but the per capita usage of each system varies considerably.
For example, checks have been popular in France but not Germany.

### Changing Networks

Large-scale, open loop payments systems are efficient and scalable.

A downside is inertia. Multiple remote parties means a common body of standards,
rules, and liability frameworks that are hard to change. Improvements may have
unseen ramifications for operations, technology, pricing, etc. They can take
years of work and may not take effect for years more.

## Checking

Overview:

* Pull
* No single owner; check clearing houses owned by banks or private processors
* U.S. law, network rules and Federal Reserve regulation
* Clears at par
* Intra-bank clearing by image or paper; batch
* Risk managed by intermediaries and end parties

A check is considered a negotiable instrument.
It instructs a bank to pay funds out of a checking account
at a depository financial institutions
and provide those funds to the person or institution names on the check.

Checks can be transferred from one person to another.

In the U.S.,
checks are a service provided by banks and other financial institutions
with regulatory permissions to operate checking accounts.

Although checking transactions begin with a piece of paper,
almost all of today's check processing is electronic.
This means the per-unit cost of checking is relatively low.

When a customer deposits a check,
their bank must collect the funds from the claimed account,
often at another bank.
This process is clearing and settlement
and happens bilaterally.

### Clearing Houses

In the 1700s and 1800s, messengers carried bags of checks between U.S. banks.
The cash or other instruments they received in exchange were subject to theft.

In 1853, the first check clearing house was established in NYC.
Banks joined the clearing house and brought deposited checks each day.
The clearing house facilitated exchange of checks
and calculated the daily net settlement for each bank.

Soon, similar clearing houses in other major cities were established
with schemes for inter-city exchange.

The Federal Reserve Bank system, formed in the early 20th century,
required its member banks to accept checks "at par".
This meant that the deposit bank would credit its customer
with "100 cents on the dollar" rather than some lesser percentage.

If it had instead adopted a discounted (not par) clearing and settlement model,
it might have looked a lot like our interchange-based card payments system.
A merchant receiving a check for $100 might be credited $98
and the bank might keep $2 as profit on the transaction.

### Automation

In the 1950s and 1960s, magnetic ink character recognition
enabled high-speed processing of checks.
The bank and account the check is drawn on appears at the bottom of a check.

Check sorters, used by clearing houses and banks on both sides,
read the MICR line and slot the checks into bins.

Depository financial institutions developed a uniform bank numbering scheme:
the transit routing number assigned by the American Banking Association.

In the 1980s and 1990s, banks added cameras to their check sorters,
capturing an image of each check as it went through the machine.
This addressed problems of managing and storing the paper.

The underlying law still required the original paper check be presented
to the check writer's bank until 2004,
when the Check Clearing of the 21st Century Act (Check 21) took effect.
The act was proposed and sponsored by the Federal Reserve Bank. It said
that an image of the original is a legal equivalent of the original paper.

In 2010, the Fed announced that 99% of checks clearing through the Fed
were being processed electronically.

### Roles

It is the job of the bank of first deposit (a.k.a. the presenting bank)
to get the check to the check writer's bank (a.k.a. the paying bank).
The presenting bank will be credited by the paying bank upon presentation.

The check writer's bank offers its customers
a demand deposit account (DDA) with checking as a feature.
The bank might offer printed check stock
with the transit routing number and account number.

The check writer writes the check with payee, date, and amount.
They deliver the check to the recipient.

The recipient deposits the check where the recipient has a DDA.
Or, they endorse the check and give it to an intermediary
who then assumes the role of recipient of the check.

The deposit bank credits the customer's account
and makes the amount usable by the customer
according to its funds availability policy.
Their policy is constrained by Federal Reserve Bank Regulation CC,
which dictates the minimum availability for checks of different kinds.
Banks may compete on more generous availability terms.

This bank of first deposit must decide how to clear the check
(how to get the check to the check writer's bank).

Highly automated banks image checks at the point of deposit,
in the ATM or at the branch teller's window.

The bank then determines whether the check is presented under some form of
bilateral agreement with the paying bank, or clearing house,
or by conversion to ACH.
If converted to ACH, the check must conform with NACHA rules.

This deposit bank must then:

* Deliver the check image to the paying bank
* Ensure that IRDs (image replacement documents) are printed and delivered
  to paying banks that do not want to receive images
* Settle with the paying bank

A processor or clearing house may handle some or all of these tasks.

Checks, at times, now clear faster than ACH or cards.
The costs of transporting paper has been mostly eliminated.
A check can now be thought of as an up-front paper order to pay,
a kind of one-time payment card.

In the future, one possibility is immediate presentation of a check image
from an ATM to a paying bank. If the paying bank adopts real-time posting
(rather than waiting to post during a nightly batch run), then the deposit bank
would know immediately if a check bounces.

### Ownership

No single entity owns the checking payments system.
Each bank chooses how to support checking.

The regulatory framework for checking is U.S. law,
the Uniform Commercial Code.
It was published in the 1950s and adopted by all 50 states.

The Federal Reserve Bank issues regulations that implement checking law.

### Volume and Trends

The checking is system is large and decentralized,
which makes volumes hard to measure.

It is seeing a sharp decline in use in certain domains
such as point of sale payment and bill payment.

### Economics and Products

Banks offset costs from check processing with revenues from check products.

Banks offer consumers and small businesses
check writing and deposit capabilities
as part of bundled "checking account" products.
Writing or depositing individual checks is seldom separately priced.
Banks see check writing as essential for bringing deposits to the bank.

Non-sufficient funds fees have historically been
a significant source of bank revenue.

Small business accounts work the same way
and typically share the same delivery platform
but often have caps on the number of checks that can be written in a month,
with fees if exceeded.

Large businesses write many checks for payroll, benefits, and vendors.
Banks offer checking accounts with transaction fee schedules for them.

