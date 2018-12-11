# ACH

* [Overview](#overview)
* [Roles](#roles)

## Overview

The ACH system:

* has "push" and "pull" payments
* is owned by banks
* is governed by NACHA rules and Federal Reserve Bank regulation
* economics are "clears at par" except for "same day"
* processes electronically in batch
* manages risk by intermediaries and end parties

ACH (Automated Clearing House) is one of largest payments systems in U.S.
The non-profit NACHA: The Electronic Payments Association serves as trustee
of the network and manages regulatory and rule-making processes,
which define the NACHA Operating Rules.

Started in 1970s by bankers working in check processing automation.
With check readers/sorters,
only MICR data was required to post transactions to customer accounts.
Why not exchange MICR data directly
instead of exchanging checks and extracting MICR data?

In the early days, ACH focused on high-volume, low-risk, repetitive transactions
like payroll, social security benefits, and insurance premiums.

ACH is wired into every demand deposit account in the country.
An enterprise who wants to make or collect a payment using ACH can do so
and plan on being able to reach every banked consumer and enterprise in U.S.

Consumers holding general purpose reloadable (GPR) prepaid cards
can have funds deposited into those cards via ACH.

ACH was designed to keep costs low for participating banks.

The U.S. government offered to pay Social Security benefits via ACH.
Every bank had customers who received Social Security,
which brought on every depository institution in the country within 15 years.

## Roles

ACH is only payments system that handles both push and pull:

* Push (ACH Credit) is initiated by payer of funds, send to receiving party
* Pull (ACH Debit) is initiated by receiver of funds, pulled from paying party

The roles are the same for both directions
but risks and economics are different.

```
originator -> ODFI -> operator -> RDFI -> receiver
```

Originator is responsible for receiver's authorization for transaction.
Originator delivers transactions to its bank
(ODFI: Originating Depository Financial Institution).

ODFI credits (push) or debits (pull) customer's account.
ODFI is liable to the network for actions of its originators.
ODFI chooses an ACH operator.

Operator sorts and forwards transactions to receiving banks
(RDFI: Receiving Depository Financial Institution).
If the RDFI uses a different operator than the ODFI,
operator performs "switch" role,
switching the transaction the other operator.
There are only two ACH operators in the U.S.

ACH operators calculate net settlement totals for their banks on daily basis.
Totals are submitted to the Fed, which manages actual settlement process
using its National Settlement Service.

This results in "zero float" among banks and their clients.

As with checking,
two banks may exchange transactions bilaterally
rather than using one of ACH operators.
Extreme low cost and efficiency of operators discourages this.
