# A Philosophy of Software Design

These notes were written while reading
[A Philosophy of Software Design][source]
as a method to aim comprehension.

[source]: https://amzn.to/2OQkBEQ

Why read it, paraphrased from [Keith Rarick](https://xph.us/):

A lot of what we do when writing and reviewing code, we do by feel.

The book provides useful definitions of software complexity and simplicity.
It looks at *why* complexity is painful:
in essence, makes code harder to understand.
This definition is perfectly aligned with programming and reviewing "by feel."

If code feels bad, that's often because it's hard (for you) to understand it.
Far from being a poor, vague motivation for wanting to avoid an approach,
it's ultimately the primary, best motivation.

The rest of the book shows ways to increase or decrease complexity
(linked back to the original definition)
and why each way makes code harder or easier to understand.

## Table of Contents

* [The Nature of Complexity][nature]
* [Working Code Isn't Enough][enough]
* [Modules Should Be Deep][deep]

[nature]: #the-nature-of-complexity
[enough]: #working-code-isnt-enough
[deep]: #modules-should-be-deep

## The Nature of Complexity

This book is about
how to design software systems to minimize their complexity.

What is "complexity"?
How can you tell if a system is unnecessarily complex?
What causes a system to become complex?

### Definition

Complexity is anything related to the structure of a software system
that makes it hard to understand and modify the system.

It might be hard to understand how a piece of code works.
It might take a lot of effort make a small change.
It might not be clear which pieces of the system to modify to make the change.
It might be difficult to fix one bug without introducing another.

Complexity is what a developer experiences.

Complexity is more apparent to readers than writers.

### Symptoms

How to notice complexity:

* Change amplification: A simple change requires many pieces of code to change.
* Cognitive load: How much a developer must know to complete a task.
* Unknown unknowns: Not obvious which code must change to complete task.

Non-symptom: number of lines of code.

Change amplification is tedious.
Cognitive load increases the cost of change.
Unknown unknowns are the worst of the types:
there is something you need to know,
but you don't know how to find out about it,
and may not even know if there is an issue.

### Causes

Complexity is caused by:

* Dependencies
* Obscurity

A dependency exists when a piece of code
cannot be understood and changed in isolation:
it relates in some way to other code,
and the other code must be considered (and maybe modified)
if the given code is changed.

Dependencies are fundamental to software and cannot be eliminated.
We often intentionally introduce dependencies.

Some goals of software design are:

* Reduce dependencies
* Make dependencies simple and obvious

Obscurity occurs when important information is not obvious.

Unclear variable/method/parameter names might require
looking up documentation or implementation of dependencies.

Inconsistency is a major contributor to obscurity.

Obscurity can be an issue of inadequate documentation
but it is also a design issue.
If a system has a clean and obvious design,
it will need less documentation.

The best way to reduce obscurity is to simplify the system design.

### Complexity is incremental

Complexity accumulates in lots of small chunks.
A single dependency or obscurity builds on another.

The incremental nature of complexity makes it hard to control.
Once it has accumulated, it is hard to eliminate.

## Working Code Isn't Enough

A strategic approach may produce better designs
and be cheaper in the long run than a tactical approach.

Most programmers' main focus is getting something working,
such as a new feature or bug fix.
This seems reasonable but can cause shortsighted behavior
if it introduces incremental complexities.

Working code isn't enough.
Also important is the long-term structure of the system.
Most of the program will be written by extending the existing code,
so new code should facilitate those future extensions.

Strategic programming requires an investment mindset
but what is the right amount of investment?
Trying to design the entire system (the "waterfall method") won't be effective.
A better approach is to make lots of small investments on a continual basis,
adding up to about 10-20% of your total development time.

Organizational code quality becomes reputational.
Facebook was known to have a tactical mindset and messy codebases.
Google was known to have taken a more strategic approach.
It can be more fun to work in an organization that cares about software design
and has a clean codebase, which helps recruit great engineers.

## Modules Should Be Deep

Software can be decomposed into a collection of modules
that are relatively independent.
Modules can be classes, subsystems, or services.

Ideally, an engineer could work on one module without worrying about another.
Modules, though, work together by calling each others' functions or methods.
There will be dependencies between modules.

To manage dependencies, we think of each module in terms of
its interface and its implementation.
The interface consists of what the caller must know,
decribing what the module does but not how.
The implementation consists of the code that
carries out the promises made by the interface.

An engineer working in a module must understand
both the interface and implementation of that module,
plus the interfaces of modules invoked by that module.

The best modules are those whose
interfaces are much simpler than their implementations.

### What's in an interface?

The interface to a module contains formal and informal information.

The formal parts are specified explicitly in the code,
and some of these can be checked for correctness by the programming language.
The formal interface of a class consists of the signatures for
all of its public methods, plus names and types of its public variables.

The informal parts are not specified in a way that can be enforced
by the programming language or other tooling.
For example, a function might delete a file named by one of its arguments.
This information needs to be understood by the engineer,
and is therefore part of its interface.
It can only be described by its documentation.

### Abstractions

A microwave oven contains complex electronics
converting alternating current into microwave radiation and
distributing that radiation throughout the cooking cavity,
but abstracts an interface of a few buttons to control timing and intensity.

An abstraction is a simplified view of an entity,
which omits unimportant details.

A detail can only be omitted from an abstraction if it is unimportant.
An abstraction can go wrong in two ways:

1. It can include details that are not important.
   This makes the abstraction more complicated than necessary,
   increasing cognitive load on engineers using it.
2. It can omit details that are important.
   This results in obscurity.
   Engineers looking only at the abstraction
   will not have all the information they need to use it correctly.
   This is a "false abstraction": it appears simple but isn't.

The key to designing abstractions is understand what is important,
and to minimize the amount of information is important.

### Deep modules

"Deep" modules are those that provide powerful functionality
yet have simple interfaces.

Consider `===` lines the interface (cost: less is better)
and `|` lines the height (benefit: more is better):

```
===========
|         |
|         |
|         |
|         |   =============================
|         |   |                           |
|         |   |                           |
-----------   -----------------------------
Deep module   Shallow module
```

The benefit provided by a module is its functionality (depth).
The cost of a module is its interface (breadth).

A module's interface represents the complexity that
the module imposes on the rest of the system:
the smaller and simpler the interface,
the less complexity that it introduces.

An example of a deep module is the garbage collector in a language such as Go.
This module has no interface at all;
it works invisibly behind the scenes to reclaim unused memory.
Adding garbage collection to a system actually shrinks its overall interface,
since it eliminates the interface for freeing objects.

### Shallow modules

A shallow module is one whose interface is complex
in comparison to the functionality that it provides.

An extreme example:

```java
private void addNullValueForAttribute(String attribute) {
  data.put(attribute, null)
}
```

For managing complexity, this method makes things worse, not better.

It:

* offers no abstraction, all its functionality is visible through its interface
* is no simpler to think about the interface than the full implementation
* is more keystrokes than manipulating the `data` variable directly
* adds complexity (a new interface for engineers to learn)
  but provides no compensating benefit

### Classitis

Conventional wisdom in programming is that classes should be small, not deep.
Programmers are told to break up larger classes into smaller ones.
The same is said for methods:

> methods longer than N lines should be divided into multiple methods

Classitis results in classes that are individually simple
but produce complexity from the accumulated interfaces.
