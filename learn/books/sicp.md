# Structure and Interpretation of Computer Programs

These notes were written while reading
[Structure and Interpretation of Computer Programs][source]
as a method to aim comprehension.

[source]: https://bit.ly/2sljBim

* [1.1 The Elements of Programming][1.1]
* [1.2 Procedures and the Processes They Generate][1.2]
* [1.3 Formulating Abstractions with Higher-Order Procedures][1.3]
* [3.1 Assignment and Local State][3.1]
* [3.2 The Environment Model of Evaluation][3.2]

[1.1]: #11-the-elements-of-programming
[1.2]: #12-procedures-and-the-processes-they-generate
[1.3]: #13-formulating-abstractions-with-higher-order-procedures
[3.1]: #31-assignment-and-local-state
[3.2]: #32-the-environment-model-of-evaluation

## 1.1 The Elements of Programming

Primitive expressions are combined into compound expressions.
Compound elements are named and manipulated as units, creating abstractions.

### 1.1.1 Expressions

Prefix notation prefixes operands, no ambiguity, always leftmost element.

```lisp
(+ 25 4 12)
```

Combinations are nested.

```lisp
(+ (* 3 5) (- 10 6))
```

### 1.1.2 Naming and the Environment

The interpreter associates value `2` with name `size`:

```lisp
define size 2
```

`define` is the simplest means of abstraction.
It allows us to refer to results of compound operations.

To associate values with symbols and later retrieve them,
the interpreter maintains memory.

This memory is called the global environment (env).

### 1.1.3 Evaluating Combinations

Think procedurally.
To evaluate (eval) combinations,
the interpreter follows a procedure:

1. Evaluate subexpressions of combination
2. Apply procedure that is the value of the leftmost subexpression (operator)
   to the arguments that are values of other subexpressions (operands)

Step 1 performs an evaluation process on each element of the combination.
The eval rule is recursive.

```lisp
(* (+ 2 (* 4 6))
   (+ 3 5 7))
```

In this example,
the eval rule is applied to four different combinations.

Each combination is a node with branches made of operators and operands.
The values of the operands accumulate up the tree.

When repeated application of subexpressions lead
not to combinations, but primitive expressions
such as numerals, built-in operators, or other names:

* values of numerals are numbers they name
* values of built-in operators are machine instruction sequences
  that carry out corresponding operations
* values of other names are objects associated with names in environment

Symbols such as `+` and `*` are also included in global environment,
associated with machine instructions that are their values.
The environment determines the meaning of symbols in expressions.

The eval rule does not handle definitions.
`define x 3` is not a combination.

Exceptions to the general eval rule are special forms.
Each special form has its own eval rule.

Each kind of expression, which its associated eval rule,
consistitute the syntax of the programming language.

### 1.1.4 Compound Procedures

Procedure definitions:

```lisp
(define (square x) (* x x))
```

A compound procedure (proc) has been named `square`.
It represents the operation of multiplying something by itself.
The thing to be multiplied is given a local name `x`,
the same as a pronoun in natural language.

General form of proc definition:

```
(define (<name> <formal parameters>) <body>)
```

`name` is a symbol associated with a proc definition in the env.

`formal parameters` (params) are names used within the body of the proc
to refer to the corresponding arguments (args) of the proc.

`name` and `formal parameters` are grouped within parentheses
in the definition the same as during the call to proc.

`body` is an expression that yields the value of proc application
when params are replaced by args to which proc is applied.

```lisp
(square 21)
(square (+ 2 5))
(square (square 3))
(+ (square x) (square y))
```

A compound proc using a compound proc:

```lisp
(define (sum-of-squares x y)
  (+ (square x) (square y)))
(sum-of-squares 3 4)
```

### 1.1.5 The Substitution Model for Procedure Application

To eval a compound proc,
the interpreter evals elements of the combination and
applies proc (value of operator) to args (values of operands).

Assume applying primitive procs to args is built into the interpreter.
For compound:
apply compound proc to args,
then eval body of proc with each param replaced by arg.

This is the substitution model for procedure application.
It helps us think,
does not describe how interpreter works.
In practice,
the substitution is accomplished with a local env for params.

#### Applicative order versus normal order

Applicative-order eval model ("eval the args and apply"):

* interpreter evals operator and operands
* then applies proc to args

Normal-order evaluation model ("fully expand and then reduce"):

* the interpreter substitutes operand expressions for params
* until an expression is obtained containing only primitive operators,
  then evals

For procedure applications that can be modeled using substitution
and yield legit values,
normal-order and applicative-order produce the same value.

Lisp uses applicative-order.

### 1.1.6 Conditional Expressions and Predicates

Case analysis:

```lisp
(define (abs x)
  (cond ((> x 0) x)
        ((= x 0) 0)
        ((< x 0) (- x))))
```

General form of conditional expression:

```
(cond (<predicate-1> <consequent-expression-1>)
      (<predicate-2> <consequent-expression-2>))
```

`cond` is followed by parenthesized pairs of expressions called clauses.
The first expression in each pair is a predicate,
an expression whose value is interpreted as true or false.

Conditionals are eval'ed:

* predicate `p1` eval'ed first
* if false, then `p2` is eval'ed
* this continues until a predicate is found who value is true,
  then interpreter returns val of corresponding consequent expression
* if no `p`s are true, val of `cond` is undefined

"Predicate" also describes procs that return true or false,
and expressions that eval to true or false.

The `abs` proc uses primitive predicates `>`, `<`, and `=`.

Another way to write `abs`:

```lisp
(define (abs x)
 (if (< x 0)
 (- x)
 x))
```

This uses the special form `if`,
a restricted type of conditional
used when there are two cases in the case analysis.

General form of if expression:

```lisp
(if <predicate> <consequent> <alternative>)
```

Logical composition operations:

```lisp
(and <e 1 > ... <e n >)
(or <e 1 > ... <e n >)
(not <e>)
```

`and` and `or` are special forms, not procs,
because subexpressions are not necessarily all evaluated.
`not` is an ordinary proc.

### 1.1.7 Square Roots by Newton's Method

Mathematical functions describe properties of things (declarative knowledge).
Computer procedures describe how to do things (imperative knowledge).

Square roots can be computed:

* given guess `y` for the square root of a number `x`
* get a better guess (one closer to the actual square root)
  by averaging `y` with `x / y`

```lisp
(define (sqrt x)
  (sqrt-iter 1.0 x))

(define (sqrt-iter guess x)
  (if (good-enough? guess x)
      guess
      (sqrt-iter (improve guess x)
                 x)))

(define (good-enough? guess x)
  (< (abs (- (square guess) x)) 0.001))

(define (improve guess x)
  (average guess (/ x guess)))

(define (average x y)
  (/ (+ x y) 2))
```

`sqrt-iter` demonstrates how iteration can be accomplished
using no special construct
other than the ability to call a proc.

### 1.1.8 Procedures as Black-Box Abstractions

`sqrt-iter` is recursive;
the proc is defined in terms of itself.

When we define the `good-enough?` proc in terms of `square`,
we regard the `square` proc as a black box.
We are not concerned with how the proc computes its result,
only that it computes the square.

Considering the values they return,
these `square` procs are the same:

```lisp
(define (square x) (* x x))

(define (square x)
  (exp (double (log x))))

(define (double x) (+ x x))
```

#### Local names

A detail that doesn't matter to the user
is the implementer's choice of names
for the procs's params.

```lisp
(define (square x) (* x x))

(define (square y) (* y y))
```

One consequence of this is that the param names of a proc
must be local to the body of the proc.

Such a name is called a bound variable (var).
The proc definition binds its params to vars.
The bound variables have the body of the proc as their scope.

If a variable is not bound, it is free.

#### Internal definitions and block structure

`sqrt` is the only proc that is important to this program's users.
The other procs (`sqrt-iter`, `good-enough?`, `improve`) create clutter.

We want to localize the subprocedures,
hiding them inside `sqrt`.
To make this possible,
we allow a proc to have internal definitions local to itself.
This is called block structure.

```lisp
(define (sqrt x)
  (define (good-enough? guess x)
    (< (abs (- (square guess) x)) 0.001))
  (define (improve guess x)
    (average guess (/ x guess)))
  (define (sqrt-iter guess x)
    (if (good-enough? guess x)
        guess
        (sqrt-iter (improve guess x) x)))
  (sqrt-iter 1.0 x))
```

Once the definitions of the auxiliary procs have been internalized,
we can simplify them.
Since `x` is bound in the definition of `sqrt`,
procs `good-enough?`, `improve`, and `sqrt-iter` are in the scope of `x`.
Thus, `x` can be a free var in the internal definitions.
This is called lexical scoping.

```lisp
(define (sqrt x)
  (define (good-enough? guess)
    (< (abs (- (square guess) x)) 0.001))
  (define (improve guess)
    (average guess (/ x guess)))
  (define (sqrt-iter guess)
    (if (good-enough? guess)
        guess
        (sqrt-iter (improve guess))))
  (sqrt-iter 1.0))
```

## 1.2 Procedures and the Processes They Generate

Procs generate common shapes for processes.
Different processes
consume computational resources of time and space
at different rates.

### 1.2.1 Linear Recursion and Iteration

This factorial proc generates a linear recursive process:

```lisp
(define (factorial n)
  (if (= n 1)
      1
      (* n (factorial (- n 1)))))
```

Its shape looks like this:

```
(factorial 6)
(* 6 (factorial 5))
(* 6 (* 5 (factorial 4)))
(* 6 (* 5 (* 4 (factorial 3))))
(* 6 (* 5 (* 4 (* 3 (factorial 2)))))
(* 6 (* 5 (* 4 (* 3 (* 2 (factorial 1))))))
(* 6 (* 5 (* 4 (* 3 (* 2 1)))))
(* 6 (* 5 (* 4 (* 3 2))))
(* 6 (* 5 (* 4 6)))
(* 6 (* 5 24))
(* 6 120)
720
```

The process expands and then contracts.
The expansion occurs as the process builds up
a chain of deferred operations (in this case, a chain of multiplications).
The contraction occurs as the operations are actually performed.
Carrying out this process requires that
the interpreter keep track of the operations to be performed later on.

In the computation of `n!`,
the length of the chain of deferred multiplications,
and the amount of info needed to keep track of it,
grows linearly with `n` (is proportional to `n`),
like the number of steps.

This factorial proc generates a linear iterative process:

```lisp
(define (factorial n)
  (fact-iter 1 1 n))

(define (fact-iter product counter max-count)
  (if (> counter max-count)
      product
      (fact-iter (* counter product)
                 (+ counter 1)
                 max-count)))
```

Its shape looks like this:

```
(factorial 6)
(fact-iter 1 1 6)
(fact-iter 1 2 6)
(fact-iter 2 3 6)
(fact-iter 6 4 6)
(fact-iter 24 5 6)
(fact-iter 120 6 6)
(fact-iter 720 7 6)
720
```

This process does not expand and contract.
At each step for `n`,
it keeps track of the current values of the vars
`product`, `counter`, and `max-count`.

An iterative process has a fixed number of state variables,
a fixed rule describing how vars should be updated
as the process moves from state to state,
and an (optional) end test
that specifies conditions under which the process should terminate.

In computing `n!`,
the number of steps required grows linearly with `n`.

In the iterative case,
vars provide a complete description of the process state at any point.
If the computation stopped between steps,
it can be resumed
by giving the interpreter the values of the three program vars.

With the recursive process,
additional info is maintained by the interpreter
not contained in the vars
which indicates "where the process is"
in negotiating the chain of deferred operations.
The longer the chain,
the more info must be maintained.

A recursive process is different than a recursive proc.
Recursive procs call themselves.
Linearly recursive processes expand and contract
due to deferred operations.

Many programming languages' interpreters
consume an amount of memory that grows with the number of proc calls
even when the process described is iterative.
As a consequence,
these languages can describe iterative processes
only via special-purpose looping constructs such as
`do`, `repeat`, `until`, `for`, and `while`.

An implementation of Scheme
that can execute an iterative process in constant space
is called tail-recursive.

### 1.2.2 Tree Recursion

A recursive proc for computing Fibonacci numbers:

```lisp
(define (fib n)
  (cond ((= n 0) 0)
        ((= n 1) 1)
        (else (+ (fib (- n 1))
                 (fib (- n 2))))))
```

To compute `(fib 5)`, compute `(fib 4)` and `(fib 3)`.
To compute `(fib 4)`, compute `(fib 3)` and `(fib 2)`.
The evolved process looks like a tree.
The branches split into two at each level (except at the bottom);
this reflects that the `fib` proc
calls itself twice each time it is invoked.

The number of steps used by the process
grows exponentially with the input.
The space required
grows linearly with the input.

In general,
a tree-recursive process
requires a number of steps
proportional to the number of nodes in the tree
and requires space
proportional to the maximum depth of the tree.

A linear iteration proc for computing Fibonacci numbers:

```lisp
(define (fib n)
  (fib-iter 1 0 n))

(define (fib-iter a b count)
  (if (= count 0)
      b
      (fib-iter (+ a b) a (- count 1))))
```

The number of steps used by the process
grows linearly with the input.

### 1.2.3 Orders of Growth

One way to describe the difference in the rates
at which processes consume computational resources
is to use the notion of order of growth
to obtain a gross measure of the resources required by a process
as the inputs become larger.

Let `n` be a param that measures the size of the problem,
and let `R(n)` be the amount of resources the process requires
for a problem of size `n`.

We say that `R(n)` has order of growth `Θ(f(n))`,
written `R(n) = Θ(f(n))`,
pronounced "theta of `f(n)`".

The steps required and the space required
for the linear recursive process in section 1.2.1
grow as `Θ(n)`.

The steps required for the linear iterative process in section 1.2.1
grow as `Θ(n)` but the space as `Θ(1)` (constant).

The steps required for the tree-recursive process in section 1.2.2
grow as `Θ(1.618^n)` and space as `Θ(n)`.

## 1.3 Formulating Abstractions with Higher-Order Procedures

Procs that manipulate procs are called higher-order procedures.

### 1.3.1 Procedures as Arguments

```lisp
(define (sum-integers a b)
  (if (> a b)
      0
      (+ a (sum-integers (+ a 1) b))))

(define (sum-cubes a b)
  (if (> a b)
      0
      (+ (cube a) (sum-cubes (+ a 1) b))))

(define (pi-sum a b)
  (if (> a b)
      0
      (+ (/ 1.0 (* a (+ a 2))) (pi-sum (+ a 4) b))))
```

These procs share a common underlying pattern,
differing only in the name of the proc,
the function of `a` used to compute the term to be added,
and the function that provides the next value of `a`.

The presence of such a pattern is strong evidence
that there is a useful abstraction waiting to be brought to the surface:
summation of a series.

We could define a new procedure `sum` that takes as its args
the lower and upper bounds `a` and `b`
with the procs `term` and `next`:

```lisp
(define (sum term a next b)
  (if (> a b)
      0
      (+ (term a)
         (sum term (next a) next b))))
```

Now we can define the original procs in terms of `sum`
along with helper procs:

```lisp
(define (sum-integers a b)
  (define (identity x)
    x)
  (sum identity a inc b))

(define (sum-cubes a b)
  (define (inc n)
    (+ n 1))
  (sum cube a inc b))

(define (pi-sum a b)
  (define (pi-term x)
    (/ 1.0 (* x (+ x 2))))
  (define (pi-next x)
    (+ x 4))
  (sum pi-term a pi-next b))
```

## 3.1 Assignment and Local State

We need strategies to help us structure large systems
so that they can be divided naturally into coherent parts
that can be separately developed and maintained.

One strategy concentrates on
the collection of objects in the system
whose behaviors may change over time.

An alternative strategy concentrates on
the streams of information that flow in the system,
much as an electrical engineer views a signal-processing system.

An object has state if its behavior is influenced by its history.
A bank account's balance depends on its history of deposits and withdrawals.

In a system of many objects, the objects are rarely independent.
Each may influence the state of others through interactions.
Each object's state is characterized by local state variables.
To model vars by ordinary symbolic names in the programming language,
the language must provide an assignment operator
to enable us to change the value associated with a name.

### 3.1.1 Local State Variables

We want a proc `withdraw` to behave like:

```
(withdraw 25)
75
(withdraw 25)
50
(withdraw 60)
"Insufficient funds"
(withdraw 15)
35
```

The expression `(withdraw 25)`,
evaluated twice,
yields different values.
This is a new kind of behavior for a proc.

To implement `withdraw`,
we can use a var `balance` to indicate the balance of and account
and define `withdraw` as a proc that accesses `balance`.

```lisp
(define balance 100)

(define (withdraw amount)
  (if (>= balance amount)
      (begin (set! balance (- balance amount))
             balance)
      "Insufficient funds"))
```

Decrementing balance is accomplished by the expression:

```lisp
(set! balance (- balance amount))
```

This uses the `set!` special form:

```
(set! <name> <new-value>)
```

Here `<name>` is a symbol and `<new-value>` is any expression.
`set!` changes `<name>` so that its value is
the result obtained by evaluating `<new-value>`.

`withdraw` also uses the `begin` special form
to cause two expressions to be evaluated:
first decrementing balance and then returning the value of balance.

```
(begin <exp1> <exp2> ... <expk>)
```

`begin` causes the expressions `<exp1>` through `<expk>`
to be evaluated in sequence
and the value of the final expression `<expk>` to be returned
as the value of the entire `begin` form.

`balance` is a name defined in the global env,
free to be examined or modified by any proc.
It would be better to make `balance` internal to `withdraw`:

```lisp
(define new-withdraw
  (let ((balance 100))
    (lambda (amount)
      (if (>= balance amount)
          (begin (set! balance (- balance amount))
                 balance)
          "Insufficient funds"))))
```

Combining `set!` with local vars is the general programming technique
we will use for constructing computational objects with local state.

This proc returns a bank account object with a specified initial balance:

```lisp
(define (make-account balance)
  (define (withdraw amount)
    (if (>= balance amount)
        (begin (set! balance (- balance amount))
               balance)
        "Insufficient funds"))
  (define (deposit amount)
    (set! balance (+ balance amount))
    balance)
  (define (dispatch m)
    (cond ((eq? m 'withdraw) withdraw)
          ((eq? m 'deposit) deposit)
          (else (error "Unknown request -- MAKE-ACCOUNT"
                       m))))
  dispatch)
```

Each call to `make-account` sets up an env
with a local var `balance`.
Within this env,
procs `deposit` and `withdraw` access `balance`
and an additional proc `dispatch` takes a "message" as input
and returns one of the two local procs.
The `dispatch` proc itself is returned
as the value that represents the bank-account object.
This is a message-passing style of programming.

`make-account` can be used as follows:

```
(define acc (make-account 100))
((acc 'withdraw) 50)
50
((acc 'withdraw) 60)
"Insufficient funds"
((acc 'deposit) 40)
90
((acc 'withdraw) 60)
30
```

Each `acc` call returns the locally defined `deposit` or `withdraw` proc,
which is then applied to the specified `amount`.

Another call to `make-account`
will produce a separate `account` object,
which maintains its own local `balance`:

```lisp
(define acc2 (make-account 100))
```

### 3.1.2 The Benefits of Introducing Assignment

We want a proc `rand` that returns an integer chosen at random.

```lisp
(define rand
  (let ((x random-init))
    (lambda ()
      (set! x (rand-update x))
      x)))
```

Successive calls to `rand`:

```
x2 = (rand-update x1)
x3 = (rand-update x2)
```

Should produce a sequence of numbers (`x1`, `x2`, `x3`)
with a uniform statistical distribution.

The same sequence could be generated
by calling `rand-update` directly
but any part of the program that used random numbers
would then have to remember the value of `x`
to be passed as an arg to `rand-update`.

### 3.1.3 The Costs of Introducing Assignment

When we introduce assignment into our language,
the substitution model of evaluation
is no longer an adequate model of proc application.

Programming without assignments is known as functional programming.

Compare two procs,
one that changes state
and one that is functional:

```lisp
(define (make-simplified-withdraw balance)
  (lambda (amount)
    (set! balance (- balance amount))
    balance))
(define (make-decrementer balance)
  (lambda (amount)
    (- balance amount)))
```

```
(define W (make-simplified-withdraw 25))
(W 20)
5
(W 10)
- 5
(define D (make-decrementer 25))
(D 20)
5
(D 10)
15
```

The substitution model can be applied to `func-withdraw`
but not `obj-withdraw` because substitution is based on
the idea that symbols are names for values.
Assignment introduces the idea that vars refer to a place
where a value can be stored
and the value stored at that place can change.

#### Sameness and change

Suppose we call `make-decrementer` twice
with the same argument to create two procs:

```lisp
(define D1 (make-decrementer 25))
(define D2 (make-decrementer 25))
```

Are `D1` and `D2` the same?
Yes, because they have the same computational behavior;
each is a proc that subtracts its input from 25.

Contrast with:

```lisp
(define W1 (make-simplified-withdraw 25))
(define W2 (make-simplified-withdraw 25))
```

Are `W1` and `W2` the same?
No, because calls to `W1` and `W2` have side effects.

A referentially transparent language supports the idea of
"equals can be substituted for equals" in an expression
without changing the value of an expression.

Without referential transparency,
it becomes difficult to formally describe
what it means for objects to be the same.

In the following model,
two bank accounts are distinct.
Transactions made by Peter
will not affect Paul's account,
and vice versa.

```lisp
(define peter-acc (make-account 100))
(define paul-acc (make-account 100))
```

In this following model,
Peter's account is the same thing as Peter's account.
They effectively have a joint bank account.
If Peter withdraws from the account,
Paul will observe less money in the account.

```lisp
(define peter-acc (make-account 100))
(define paul-acc peter-acc)
```

It can be confusing that the same account
has two different names.
To find all the places in the program that reference `peter-acc`,
we must also look for `paul-acc`.

#### Pitfalls of imperative programming

Programming with many assignments is known as imperative programming.

Imperative programs are susceptible to bugs
related to the order of assignments.
THe programmer has to carefully consider
which version of the var is being used.

The complexity becomes worse when
several processes execute concurrently.

## 3.2 The Environment Model of Evaluation

An environment is a sequence of frames.

Each frame:

* is a table (possibly empty) of bindings,
  which associate variable names
  with their corresponding values
* contains at most one binding for a var
* contains a pointer to its enclosing environment
  unless the frame is global

The value of a var is the value given by
the binding of the var in the first frame in the env
that contains a binding for that var.

If no frame in the sequence specifies a binding for the var,
the var is unbound in the env.

Expressions in a programming language do not, in themselves,
have any meaning.
An expression acquires meaning with respect to an env
in which it is eval'ed.

Even `(+ 1 1)` depends on the symbol `+` being bound
in the global env to a primitive addition procedure.k

We will suppose there is a global env,
consisting of a single frame,
with no enclosing env,
that includes values for the symbols
associated with primitive procs.

### 3.2.1 The Rules for Evaluation

The spec for how the interpreter
evals a combination remains the same as section 1.1.3:

1. Evaluate subexpressions of combination
2. Apply procedure that is the value of the leftmost subexpression (operator)
   to the arguments that are values of other subexpressions (operands)

The environment model replaces the substitution model
in specifying what it means to apply a compound proc to args.

In the env model,
a proc is always a pair consisting of some code
and a pointer to an env.

Procs are created by eval'ing a `lambda` expression.
This produces a proc whose code is obtained from
the text of the `lambda` expression
and whose env is the env in which the `lambda` was eval'ed.

This proc definition is evaluated in the global env:

```lisp
(define (square x)
  (* x x))
```

It is syntactic sugar for an underlying `lamda` expression.
This is equivalent:

```lisp
(define square
  (lambda (x) (* x x)))
```

It evals `(lambda (x) (* x x))` and binds `square`
to the resulting value in its env.

To apply a proc to args:

* construct a frame,
  binding the proc's params to the calling args.
* eval the body of the proc
  in the context of the new env constructed.
  The new frame has as its enclosing env
  the env part of the proc being applied

Evaluating `(set! <variable> <value>)`
finds the first frame in the env that contains a binding for the var
and modifies that frame.
If the var is unbound in the env,
`set!` signals an error.
