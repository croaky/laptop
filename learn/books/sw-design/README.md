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

* [The Nature of Complexity](#the-nature-of-complexity)
* [Working Code Isn't Enough](#working-code-isnt-enough)
* [Modules Should Be Deep](#modules-should-be-deep)
* [Information Hiding and Leakage](#information-hiding-and-leakage)
* [General Purpose Modules are Deeper](#general-purpose-modules-are-deeper)
* [Different Layer, Different
  Abstraction](#different-layer-different-abstraction)
* [Pull Complexity Downwards](#pull-complexity-downwards)
* [Better Together or Better Apart?](#better-together-or-better-apart)

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

Organizational code quality affects reputation.
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
describing what the module does but not how.
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

## Information Hiding (and Leakage)

If modules should be deep,
what are some techniques to create deep modules?

### Information hiding

The most important technique for creating deep modules is information hiding.
Each module encapsulates knowledge of design decisions,
embedded in the implementation but not visible in the interface.

For example:

* How to store and access data
* What kind of data structure to use
* We'll use a particular JSON parser
* Pagination size
* Most files will be small

Information hiding reduces complexity by:

* Simplifying the interface to a module
* Making it easier to evolve the system

When designing a module,
if you can hide more information,
you should be able to simplify the module's interface,
and this makes the module deeper.

Hiding variables and methods in a class with `private`
isn't the same thing as information hiding.
Private elements can help hide information
but information about them can still be exposed
through public methods such as setters and getters.

### Information leakage

Information leakage occurs when a design decision
is reflected in multiple modules,
creating a dependency between them:
any change to that design decision
will require changes to all involved modules.

For example,
if two modules depend on a file format
so that one can write and the other can read,
they both depend on the file format.
Dependencies that aren't obvious through the interface are especially harmful.

If you encounter leakage between modules,
ask "How can I reorganize this code
so knowledge of this design decision
only affects one module?"

It might make sense to merge two modules.

It might make sense to extract a new module
responsible only for that design decision.
This will only be effective if you can design a simple interface
that abstracts away the details.
If the new module exposes most of the knowledge through its interface,
then it won't provide much value:
it replaces back-door leakage with leakage through an interface.

### Temporal decomposition

In temporal decomposition,
the structure of a system corresponds to the time order
in which operations occur.

Consider an application that reads a file,
modifies its contents,
then writes the file out again.
If each step occurs in its own module,
both file reading and writing depend on the file format,
leaking that knowledge.

The solution is to combine the core mechanism
for reading and writing files into a single class.

When designing modules,
focus on the knowledge that's needed to perform each task,
not the order in which the tasks occur.

### Example: HTTP requests

To implement an HTTP server,
we need to read the HTTP request from a network connection
and parse each line of the request
(the request line, its headers, an empty line, and optional body).

We could separate these steps into two modules:
one to read the request from the network connection
and one to parse the string.
This is temporal decomposition,
leaking information because
an HTTP request can't be read without parsing much of the message
such as the `Content-Length` header.
This structure also creates extra complexity for callers
who have to invoke two methods in a particular order.

Information hiding can often be improved by making a class slightly larger.

One reason to do this is to reduce code duplication.

Another reason is to raise the level of the interface:
rather than having separate methods for each step,
have a single method that performs the entire computation.

### Example: HTTP parameter handling

Parameters can be specified in the HTTP request line
or sometimes in the body.
Each parameter has a name and value.
The values are encoded using "URL encoding".
In order to process a request,
the server will want decoded values of the parameters.

Servers don't need to care whether a parameter is specified
in the request line or body.
So, this distinction can be hidden from callers
and the parameters can be merged from both locations.

URL encoding can also be hidden in the same module.

A method such as `getParams` that returns the parameters data structure
is too shallow because it exposes the internal representation.
This approach makes more work for callers:
they must invoke `getParams`,
then call another method to get the specific parameter from the structure.
If the data structure is a reference,
callers must also realize they should not modify the result
since it affects the internal state of the module.

Avoid exposing internal data structures as much as possible.

A better interface is something like:

* `getParam`
* `getParamInt`
* etc.

These methods get the parameter,
type cast it,
and handle errors.

### Example: I/O defaults

Defaults illustrate that interfaces should be designed
to make the common case simple.

Buffering in I/O is so universally desirable that
it should be provided by I/O modules by default.

The best features are the ones you get without even knowing they exist.

## General Purpose Modules are Deeper

A common decision is:
are you designing a general purpose module
or a special purpose module?

General purpose means addressing a broad range of problems,
not only the ones that are important today.
Spend a bit more time up front to save time later.

It's hard to predict the future needs of software,
so general purpose might include facilities that are never needed.

If something is too general purpose,
it might not do a good job of solving the problem you have today.

So, maybe it's better to focus on today's needs,
building only what we know we need in a specialized way?
If we discover additional uses later,
we can refactor to make it general purpose.
This feels incremental.

### Make module somewhat general purpose

The sweet spot is when a module's functionality reflects current needs
but its interface is general enough to support multiple uses.

### Example: storing text for an editor

Build a text editor, including UI.
Display a file and allow users to point, click, and type to edit the file.

It might be useful to write an underlying module that manages text.

A special purpose API might be:

```java
void backspace(Cursor cursor);
void delete(Cursor cursor);
void deleteSelection(Selection selection);
```

This approach:

* generates a large number of shallow methods
* creates information leakage between UI and text,
  adding cognitive load for developers working on either UI code or text class

One of the goals of module design is to
allow each class to be developed independently.

A general purpose API might be:

```java
void insert(Position position, String newText);
void delete(Position start, Position end);
Position changePosition(Position position, int numChars);
```

`delete` and `backspace` in the specific implementation
becomes this in the generic implementation:

```java
text.delete(cursor, text.changePosition(cursor, 1));
text.delete(text.changePosition(cursor, -1), cursor);
```

To a developer working in the UI module,
it is obvious that these are `delete` and `backspace` operations.
They do not need to go to the text class or read docs to verify behavior.

This approach has less code overall.

If future functionality such as "find and replace" is written,
most of the code is already in place in the generic approach.
All that would be needed is:

```java
Position findNext(Position start, String string);
```

The specialized class implementing `delete` and `backspace`
would not be re-usable.

### Generality leads to better information hiding

The `backspace` method was a false abstraction.
It purported to hide information about which characters are deleted,
but the UI module and its developers really needs to know about this.

An important element in software design
is identifying who needs to know what, and when.

## Different Layer, Different Abstraction

Software is composed in layers.
Higher layers use facilities provided by lower layers.
Each layer should provide a different abstraction from layers above and below.

### Pass-through methods

A pass-through method does little more except invoke another method
whose signature is similar or identical to the calling method.

Pass-through methods make classes shallower:
they increase the interface complexity of the class
but don't increase the total functionality of the system.

Pass-through methods also create dependencies between classes.

The interface to a piece of functionality
should be in the same class that implements the functionality.

The solution is to refactor in one of these ways:

1. Expose lower-level class directly to callers of higher-level class
2. Redistribute functionality between classes
3. Merge classes

### When interface duplication is OK

One example where it's useful for a method to call another method
with the same signature is a dispatcher.

A dispatcher is a method that uses its arguments to select
one of several other methods to invoke.
Then, it passes most of all of its arguments to the chosen method.
Choosing the method is useful functionality.

An HTTP request router is an example of a dispatcher.

Another example of useful interface duplication is when several methods
provide a different implementation with the same interface.

For example, database drivers within an adapter such as Ruby's `ActiveRecord`
may provide different implementations for Postgres or MySQL.
Or, stream writers may use Go's `io.Writer` interface
may provide different implementations to write bytes
to a file or to an HTTP connection.

In this case, the same interface reduces cognitive load.
Once you've worked with one interface, it is easier to work with the others.

Methods like this are usually in the same layer of abstraction
and do not invoke each other.

### Decorators

The decorator design pattern takes an existing object
and extends its functionality.

For example, a `Window` class may implement a window and a `ScrollableWindow`
might decorate `Window` with horizontal and vertical scrollbars.

The motivation for decorators is to separate special-purpose extensions
from a more generic core but decorators tend to be shallow
and contain many pass-through methods.

Alternative considerations to decorators:

* Could the functionality be in the underlying class?
* If the functionality is specific to a use case,
  could it merged with the use class rather than creating a separate class?
* Could the new functionality be merged into an existing decorator,
  resulting in a single deeper decorator instead of multiple shallow ones?
* Does the functionality need to wrap underlying functionality,
  or could it be implemented stand-alone?

### Pass-through variables

Another form of API duplication is a pass-through variable,
which is a variable that is passed through a long chain of methods.

Pass-through variables add complexity because
they force all the intermediate methods to be aware of their existence,
even though the methods have no use for the variables.

Eliminating pass-through variables can be challenging:

* Store information in a different object,
  but it may itself be a pass-through variable.
* Store information in a global variable,
  which almost always causes other problems,
* Introduce a context object that stores all the application's global state.
  There is one context object per instance of the system.

## Pull Complexity Downwards

Unavoidable complexity could be handled
by users of a module or
by internals of the module.

Since most modules have more users than developers,
it is more important for a module to have a simple interface
than a simple implementation.

Temptations of a module developer to "let the caller handle it":

* raise an exception
* define a configuration parameter to control a policy

These approaches amplify complexity.
Many people must deal with a problem instead of one.
If a class throws an exception, every caller must handle it.
If a configuration parameter is exported,
every sysadmin will need to learn to set them.

The goal is to minimize overall system complexity.

### Example: configuration parameters

Rather than determining a behavior internally,
a class can export configuration parameters to control its behavior such as
the size of a cache or number of times to retry a request.

The benefit is users can tune the system
for their particular requirements and workloads.
In some cases, it is hard for lower level code to know the best policy to apply
and users are more familiar with their domain.

In other cases, it is difficult for users to determine the right values.
Making a decision internally reduces the user's work.
It also avoids backwards-compatibility issues.

Before exporting a configuration parameter, ask:

> Will users (or higher-level modules) be able to determine a better value
> than we can determine internally?

## Better Together or Better Apart?

The goal is to minimize overall system complexity.

To achieve this goal, we could divide the system
into a large number of small components.
The smaller the component, the simpler each component will be.

The act of dividing creates additional complexity that was not there:

* more components means more difficulty to distinguish between them
  and find the right one for each job
* additional code to manage
* separation: the code is farther apart than before.
  If the components are truly independent,
  this is good (the developer can focus on a single component at a time).
  If there are dependencies between them,
  this is bad (the developer needs to flip between them, or is unaware of them).
* duplication

Indications two pieces of code may be related:

* they share information. For example, depend on syntax of a document
* they are used together bi-directionally
* they overlap conceptually. For example: searching for a substring and
  case conversion are both string manipulation. Flow control and
  reliable delivery are both network communication.
* it is hard to understand one of the pieces without looking at another
