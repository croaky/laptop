# Test-Driven Development By Example

These notes were written while reading
[Test-Driven Development By Example][source]
as a method to aim comprehension.

[source]: https://amzn.to/2My3KW9

## Table of Contents

* [Introduction][intro]
* [Multi-Currency Money][multi]
* [Degenerate Objects][degen]

[intro]: #introduction
[multi]: #multi-currency-money
[degen]: #degenerate-objects

## Introduction

Test-driven development is a set of techniques
that any software engineer can follow,
which encourages simple designs and test suites that inspire confidence.

Following these two rules can help us work to our potential:

* Write a failing automated test before you write code
* Remove duplication

The rhythm of Test-Driven Development (TDD) can be summarized:

* Add a little test
* Run all tests and fail
* Make a little change
* Run all tests and succeed
* Refactor to remove duplication

## Multi-Currency Money

We'll write `TODO`s
to remind us what we need to do,
to keep us focused,
and to tell us when we're finished.

When we write a test,
we imagine the perfect interface for our operation.
We tell a story about how the API will look from the outside.

```java
public void testMultiplication() {
  Dollar five= new Dollar(5);
  five.times(2);
  assertEquals(10, five.amount);
}
```

Some things smell about this API such as side effects.
We'll add a `TODO` for any smells and move on.

This test causes four compile errors:

* No class `Dollar`
* No constructor
* No method `times(int)`
* No field `amount`

Let's take them one at a time.
Define the class:

```java
Dollar(int amount)
```

Stub the implementation for `times()`:

```java
void times(int multiplier) {
}
```

Add an `amount` field:

```java
int amount;
```

The test now changes from errors to failures.

Get the test to pass ("green"):

```java
int amount= 10;
```

This works but introduces a dependency between the code and test.

Dependency is a key problem in software development at all scales.
If dependency is the problem,
duplication is the symptom.

Eliminating duplicated code often eliminates dependency.
That's why the second rule appears in TDD.
By eliminating duplication before we go onto the next test,
we maximize our chances of getting the next test running with only one change.

Smallest step possible:

```java
int amount= 5 * 2;
```

The duplication is now more obvious.
Smallest step possible:

```java
int amount;

void times(int multiplier) {
  amount= 5 * 2;
}
```

The tests still pass.

These steps may seem too small.
If you can make steps too small,
you can certainly make steps the right size.
If you only take larger steps,
you'll never know if smaller steps are appropriate.

Continuing to get rid of duplication:

```java
Dollar(int amount) {
  this.amount= amount;
}

void times(int multiplier) {
  amount *= multiplier;
}
```

Our first test is done.
Next we'll take care of the strange side effects
and any other `TODO`s we wrote along the way.

## Degenerate Objects

The general TDD cycle is:

* Write a test.
  Invent the interface you wish you had.
* Make it run.
  If a clean, simple solution is obvious, then write it.
  If not, write a `TODO` and get back to the main problem.
* Make it right.
  Remove duplication.

The goal as Ron Jeffries said is:

> Clean code that works.

Clean code that works is often out of our reach most of the time.

So, divide and conquer.
Solve the "that works" part first.
Solve the "clean code" part second.

Let's address the side effects in our interface.
This will be an API change and require a test change:

```java
public void testMultiplication() {
  Dollar five= new Dollar(5);
  Dollar product= five.times(2);
  assertEquals(10, product.amount);
  product= five.times(3);
  assertEquals(15, product.amount);
}
```

Make the test pass:

```java
Dollar times(int multiplier) {
  return new Dollar(amount * multiplier);
}
```

Delete the side effect `TODO`.

Two common strategies for getting to green are:

* Fake It: return a constant.
  Gradually replace constants with variables until have real code.
* Use Obvious Implementation: type in the real implementation.

When everything is going smoothly and we know what to type,
we can put in obvious implementation after obvious implementation.

When we hit an unexpected test failure,
quickly shift backwards to faking the implementation
and refactoring to the right code.

When confidence returns,
shift forwards to obvious implementations.

There is a third strategy, Triangulation, which we will demonstrate later.

The translation of a feeling (for example, disgust at side effects)
into a test (for example, multiple the same `Dollar` twice)
is a common theme of TDD.

The longer I do this,
the better able I am to translate my aesthetic judgements into tests.
