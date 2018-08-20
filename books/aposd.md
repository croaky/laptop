# A Philosophy of Software Design

These notes were written while reading
[A Philosophy of Software Design][source]
as a method to aim comprehension.

[source]: https://amzn.to/2OQkBEQ

* [The Nature of Complexity][nature]

[nature]: #the-nature-of-complexity

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
