# Chapter 1

Primitive expressions are combined into compound expressions.
Compound elements are named and manipulated as units, creating abstractions.

## 1.1.1 Expressions

Prefix notation prefixes operands, no ambiguity, always leftmost element.

```
(+ 25 4 12)
```

Combinations are nested.

```
(+ (* 3 5) (- 10 6))
```

## 1.1.2 Naming and the Environment

Interpreter associates value `2` with name `size`:

```
define size 2
```

`define` is simplest means of abstraction,
allows us to refer to results of compound operations.

Associating values with symbols and later retrieving them
means interpreter must maintain memory to track name-object pairs.

This memory is called the global environment.

## 1.1.3 Evaluating Combinations

A goal of chapter is to think procedurally.
To evaluated combations, interpreter itself follows a procedure:

1. Evaluate subexpressions of combination
2. Apply procedure that is the value of the leftmost subexpression (operator)
   to the arguments that are values of other subexpressions (operands)

Important points about processes: first step means first perform eval process on
each element of the combination. Thus, eval rule is recursive in nature.

```
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

## 1.1.4

Procedure definitions:

```
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

```
(square 21)
(square (+ 2 5))
(square (square 3))
(+ (square x) (square y))
```

A compound proc using a compound proc:

```
(define (sum-of-squares x y)
  (+ (square x) (square y)))
(sum-of-squares 3 4)
```

## 1.1.5 The Substitution Model for Procedure Application

To eval a compound proc, the interpreter evals elements of the combination and
applies proc (value of operator) to args (values of operands).

Assume applying primitive procs to args is built into interpreter. For compound:
apply compound proc to args, eval body of proc with each param replaced by arg.

This is the substitution model for procedure application. It helps us think,
does not describe how interpreter works. In practice, the "substitution" is
accomplished with a local env for params.

### Applicative order versus normal order

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

## 1.1.6 Conditional Expressions and Predicates

Case analysis:

```
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

```
(define (abs x)
 (if (< x 0)
 (- x)
 x))
```

This uses special form `if`, a restricted type of conditional used when there
are precisely two cases in the case analysis.

The general form of an if expression is:

```
(if <predicate> <consequent> <alternative>)
```

Logical composition operations:

```
(and <e 1 > ... <e n >)
(or <e 1 > ... <e n >)
(not <e>)
```

`and` and `or` are special forms, not procs, because subexpressions are not
necessarily all evaluated. `not` is an ordinary proc.
