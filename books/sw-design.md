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
