# Structure and Interpretation of Computer Programs

These notes were written while reading [the original SICP text][ori]
as a method to aim comprehension.

* [1.1 The Elements of Programming][1.1]
* [1.2 Procedures and the Processes They Generate][1.2]
* [1.3 Formulating Abstractions with Higher-Order Procedures][1.3]
* [3.1 Assignment and Local State][3.1]

[ori]: https://mitpress.mit.edu/sites/default/files/sicp/full-text/book/book-Z-H-4.html
[1.1]: #11-the-elements-of-programming
[1.2]: #12-procedures-and-the-processes-they-generate
[1.3]: #13-formulating-abstractions-with-higher-order-procedures
[3.1]: #31-assignment-and-local-state

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

Interpreter associates value `2` with name `size`:

```lisp
define size 2
```

`define` is simplest means of abstraction,
allows us to refer to results of compound operations.

Associating values with symbols and later retrieving them
means interpreter must maintain memory to track name-object pairs.

This memory is called the global environment.

### 1.1.3 Evaluating Combinations

A goal of this chapter is to think procedurally.
To evaluate combinations, interpreter itself follows a procedure:

1. Evaluate subexpressions of combination
2. Apply procedure that is the value of the leftmost subexpression (operator)
   to the arguments that are values of other subexpressions (operands)

Important points about processes: first step means first perform eval process on
each element of the combination. Thus, eval rule is recursive in nature.

```lisp
(* (+ 2 (* 4 6))
   (+ 3 5 7))
```

The eval rule is applied to four different combinations.

Each combination is a node with branches made of operators and operands.
The values of the operands accumulate up the tree.

When repeated application of subexpressions lead to not combinations,
but primitive expressions such as numerals, built-in operators, or other names:

* values of numerals are numbers they name
* values of built-in operators are machine instruction sequences that carry out
  corresponding operations
* values of other names are objects associated with names in environment

Symbols such as `+` and `*` are also included in global environment,
associated with machine instructions that are their "values".
The environment determines the meaning of symbols in expressions.

The evaluation rule does not handle definitions. `define x 3` is not a
combination. Exceptions to general eval rule are called "special forms".
Each special form has its own eval rule. Each kind of expression, which its
associated eval rule, consistitute the syntax of the programming language.

### 1.1.4 Compound Procedures

Procedure definitions:

```lisp
(define (square x) (* x x))
```

A compound procedure has been named `square` representing the operation of
multiplying something by itself. The thing to be multiplied is given a local
name `x`, same as a pronoun in natural language.

The general form of proc definition is:

```
(define (<name> <formal parameters>) <body>)
```

The `name` is a symbol to be associated with proc definition in env.
Formal `params` are names used within body of proc to refer to corresponding
arguments of proc. `body` is an expression that yields value of proc application
when formal params are replaced by args to which proc is applied. `name` and
`params` are grouped within parens in definition same as during call to proc.

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

To eval a compound proc, the interpreter evals elements of the combination and
applies proc (value of operator) to args (values of operands).

Assume applying primitive procs to args is built into interpreter. For compound:
apply compound proc to args, eval body of proc with each param replaced by arg.

This is the substitution model for procedure application. It helps us think,
does not describe how interpreter works. In practice, the "substitution" is
accomplished with a local env for params.

#### Applicative order versus normal order

Applicative-order evaluation model:
interpreter evals operator and operands, applies proc to args.
Or, "eval the args and apply".

Normal-order evaluation model:
interpreter substitutes operand expressions for params until
an expression is obtained containing only primitive operators, then evals.
Or, "fully expand and then reduce".

For procedure applications that can be modeled using substitution and yield
legit values, normal-order and applicative-order produce same value.

Lisp uses applicative-order.

### 1.1.6 Conditional Expressions and Predicates

Case analysis:

```lisp
(define (abs x)
  (cond ((> x 0) x)
        ((= x 0) 0)
        ((< x 0) (- x))))
```

The general form of a conditional expression consists of the symbol `cond`
followed by parenthesized pairs of expressions called "clauses". The first
expression in each pair is a "predicate" -- an expression whose value is
interpreted as true or false.

Conditionals are evaluated:

* predicate `p1` eval'ed first
* if false, then `p2` is eval'ed
* this continues until a predicate is found who value is true,
  in which case interpreter returns val of corresponding "consequent expression"
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

This uses special form `if`, a restricted type of conditional used when there
are precisely two cases in the case analysis.

The general form of an if expression is:

```lisp
(if <predicate> <consequent> <alternative>)
```

Logical composition operations:

```lisp
(and <e 1 > ... <e n >)
(or <e 1 > ... <e n >)
(not <e>)
```

`and` and `or` are special forms, not procs, because subexpressions are not
necessarily all evaluated. `not` is an ordinary proc.

### 1.1.7 Square Roots by Newton's Method

Mathematical functions describe properties of things (declarative knowledge).
Computer procedures describe how to do things (imperative knowledge).

Square roots can be computed with Newton's method of successive approximations:
given guess `y` for the square root of a number `x`,
get a better guess (one closer to the actual square root)
by averaging `y` with `x / y`.

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
using no special construct other than the ability to call a procedure.

### 1.1.8 Procedures as Black-Box Abstractions

`sqrt-iter` is recursive; the procedure is defined in terms of itself.

When we define the `good-enough?` procedure in terms of `square`,
we regard the square procedure as a "black box."
We are not concerned with how the procedure computes its result,
only that it computes the square.

Thus, considering only the values they return,
the following `square` procedures should be indistinguishable.

```lisp
(define (square x) (* x x))

(define (square x)
  (exp (double (log x))))

(define (double x) (+ x x))
```

#### Local names

One detail that should not matter to the user
is the implementer's choice of names for the procedure's formal parameters.

```lisp
(define (square x) (* x x))

(define (square y) (* y y))
```

One consequence of this is that the parameter names of a procedure
must be local to the body of the procedure.

Such a name is called a bound variable.
The procedure definition binds its formal parameters to variables.
The bound variables have the body of the procedure as their scope.

If a variable is not bound, we say that it is free.

#### Internal definitions and block structure

The problem with our current program is that
`sqrt` is the only procedure that is important to users.
The other procedures (`sqrt-iter`, `good-enough?`, `improve`) create clutter.

We would like to localize the subprocedures, hiding them inside `sqrt`.
To make this possible,
we allow a procedure to have internal definitions local to that procedure.
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

In addition to internalizing the definitions of the auxiliary procedures,
we can simplify them.
Since `x` is bound in the definition of `sqrt`,
procedures `good-enough?`, `improve`, and `sqrt-iter` are in the scope of `x`.
Thus, we can allow `x` to be a free variable in the internal definitions.
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

Procedures generate common shapes for processes.
Processes consume computational resources of time and space at different rates.

### 1.2.1 Linear Recursion and Iteration

This factorial procedure generates a linear recursive process:

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
and hence the amount of information needed to keep track of it,
grows linearly with `n` (is proportional to `n`),
like the number of steps.

This factorial procedure generates a linear iterative process:

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
it keeps track of the current values of the variables
`product`, `counter`, and `max-count`.

An iterative process has a fixed number of state variables,
a fixed rule describing how vars should be updated
as the process moves from state to state,
and an (optional) end test
that specifies conditions under which the process should terminate.

In computing `n!`, the number of steps required grows linearly with `n`.

In the iterative case,
vars provide a complete description of the process state at any point.
If the computation stopped between steps,
the computation can be resumed by supplying the interpreter
with the values of the three program variables.

With the recursive process,
there is additional info maintained by the interpreter
not contained in the vars
which indicates "where the process is"
in negotiating the chain of deferred operations.
The longer the chain, the more info must be maintained.

A recursive process is different than a recursive procedure.
Recursive procedures call themselves.
Linearly recursive processes expand and contract due to deferred operations.

Many programming languages interpreters
consume an amount of memory that grows with the number of procedure calls
even when the process described is iterative.
As a consequence, these languages can describe iterative processes
only via special-purpose looping constructs such as
`do`, `repeat`, `until`, `for`, and `while`.

An implementation of Scheme
that can execute an iterative process in constant space
is called tail-recursive.

### 1.2.2 Tree Recursion

Consider this recursive procedure for computing Fibonacci numbers:

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
The branches split into two at each level (except at the bottom); this reflects
that the `fib` procedure calls itself twice each time it is invoked.

The number of steps used by the process grows exponentially with the input.
The space required grows linearly with the input.

In general, a tree-recursive process
requires a number of steps proportional to the number of nodes in the tree
and requires space proportional to the maximum depth of the tree.

Consider this linear iteration procedure for computing Fibonacci numbers:

```lisp
(define (fib n)
  (fib-iter 1 0 n))

(define (fib-iter a b count)
  (if (= count 0)
      b
      (fib-iter (+ a b) a (- count 1))))
```

The number of steps used by the process grows linearly with the input.

### 1.2.3 Orders of Growth

One way to describe the difference in the rates
at which processes consume computational resources
is to use the notion of order of growth
to obtain a gross measure of the resources required by a process
as the inputs become larger.

Let `n` be a parameter that measures the size of the problem,
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

Procedures that manipulate procedures are called higher-order procedures.

### 1.3.1 Procedures as Arguments

Consider the following procedures:

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

They share a common underlying pattern,
differing only in the name of the procedure,
the function of a used to compute the term to be added,
and the function that provides the next value of a.

The presence of such a pattern is strong evidence
that there is a useful abstraction waiting to be brought to the surface:
summation of a series.

We could define a new procedure `sum` that takes as its arguments
the lower and upper bounds `a` and `b`
with the procedures `term` and `next`:

```lisp
(define (sum term a next b)
  (if (> a b)
      0
      (+ (term a)
         (sum term (next a) next b))))
```

Now we can define the original procedures in terms of `sum`
along with helper procedures:

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
so that they can be divided "naturally" into coherent parts
that can be separately developed and maintained.

One strategy concentrates on the collection of objects in the system
whose behaviors may change over time.

An alternative strategy concentrates on the streams of information
that flow in the system,
much as an electrical engineer views a signal-processing system.

An object has state if its behavior is influenced by its history.
A bank account's balance depends on its history of deposits and withdrawals.

In a system of many objects, the objects are rarely independent.
Each may influence the state of others through interactions.
Each object's state is characterized by local state variables.
To model state variables by ordinary symbolic names in the programming language,
the language must provide an assignment operator
to enable us to change the value associated with a name.

### 3.1.1 Local State Variables

We want a procedure `withdraw` to behave like:

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

Observe that the expression `(withdraw 25)`,
evaluated twice, yields different values.
This is a new kind of behavior for a procedure.

To implement `withdraw`,
we can use a variable `balance` to indicate the balance of and account
and define `withdraw` as a procedure that accesses `balance`.

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

This uses the `set!` special form, whose syntax is:

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

causes the expressions `<exp1>` through `<expk>`
to be evaluated in sequence
and the value of the final expression `<expk>` to be returned
as the value of the entire `begin` form.

`balance` is a name defined in the global environment
and is freely accessible to be examined or modified by any procedure.
It would be better if we could make `balance` internal to `withdraw`:

```lisp
(define new-withdraw
  (let ((balance 100))
    (lambda (amount)
      (if (>= balance amount)
          (begin (set! balance (- balance amount))
                 balance)
          "Insufficient funds"))))
```

Combining `set!` with local variables is the general programming technique
we will use for constructing computational objects with local state.

When we first introduced procedures,
we also introduced the substitution model of evaluation (section 1.1.5)
to provide an interpretation of what procedure application means.
When we introduce assignment into our language,
substitution is no longer an adequate model of procedure application.

This procedure returns a bank account object with a specified initial balance:

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

Each call to `make-account` sets up an environment
with a local state variable `balance`.
Within this environment,
procedures `deposit` and `withdraw` access `balance`
and an additional procedure `dispatch` takes a "message" as input
and returns one of the two local procedures.
The `dispatch` procedure itself is returned as
the value that represents the bank-account object.
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

Each `acc` call returns the locally defined `deposit` or `withdraw` procedure,
which is then applied to the specified `amount`.

Another call to `make-account`:

```lisp
(define acc2 (make-account 100))
```

will produce a separate `account` object,
which maintains its own local `balance`.
