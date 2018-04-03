# Decorators

A decorator is a design pattern.
Its intent, as described in [Design Patterns] by the Gang of Four is:

> Attach additional responsibilities to an object dynamically.
> Decorators provide a flexible alternative to subclassing
> for extending functionality.

[Design Patterns]: https://www.amazon.com/Design-Patterns-Elements-Reusable-Object-Oriented-ebook/dp/B000SEIBB8

## Use a decorator instead of inheritance

A common decorator example is the "coffee with milk and sugar" example.
Here's a Ruby implementation of that example using class inheritance
(subclassing):

```ruby
class CoffeeWithSugar < Coffee
  def cost
    super + 0.2
  end
end

class CoffeeWithMilkAndSugar < Coffee
  def cost
    super + 0.4 + 0.2
  end
end
```

The problems with inheritance include:

* Choices are made statically.
* Clients can't control how and when to decorate a component.
* Tight coupling.
* Changing the internals of the superclass means all subclasses must change.

In Ruby, including a module is also inheritance:

```ruby
module Milk
  def cost_of_milk
    0.4 if milk?
  end
end

class Coffee
  include Milk
  include Sugar

  def cost
    2 + cost_of_milk + cost_of_sugar
  end
end
```

## How a decorator works

Using Gang of Four terms,
a decorator is an object that encloses a component object.
It also:

* conforms to interface of component so its presence is transparent to clients.
* forwards (delegates) requests to the component.
* performs additional actions before or after forwarding.

This approach is more flexible than inheritance
because you can mix and match responsibilities in more combinations
and because the transparency lets you nest decorators recursively,
it allows for an unlimited number of responsibilities.

## Alternative implementations in Ruby

Common variations of decorator implementations in Ruby include:

* `module` + `extend` + `super` decorator
* Plain Old Ruby Object decorator
* `class` + `method_missing` decorator
* `SimpleDelegator` + `super` + `__getobj__` decorator

## `module` + `extend` + `super` decorator

This variation is implemented like this:

```ruby
class Coffee
  def cost
    2
  end
end

module Milk
  def cost
    super + 0.4
  end
end

module Sugar
  def cost
    super + 0.2
  end
end

coffee = Coffee.new
coffee.extend(Milk)
coffee.extend(Sugar)
coffee.cost   # 2.6
```

The benefits are:

* it delegates through all decorators
* it has all of the original interface because it is the original object

The drawbacks are:

* can not use the same decorator more than once on the same object
* difficult to tell which decorator added the functionality

## The "Plain Old Ruby Object" (PORO) decorator

I start with this style of decorator in my Ruby programs,
including Rails apps,
and then move to something else only when this style fails:

```ruby
class Coffee
  def cost
    2
  end

  def origin
    "Colombia"
  end
end

class Milk
  def initialize(component)
    @component = component
  end

  def cost
    @component.cost + 0.4
  end
end

coffee = Coffee.new
Sugar.new(Milk.new(coffee)).cost  # 2.6
Sugar.new(Sugar.new(coffee)).cost # 2.4
Sugar.new(Milk.new(coffee)).class # Sugar
Milk.new(coffee).origin           # NoMethodError
```

The benefits are:

* can be wrapped infinitely using Ruby instantiation
* delegates through all decorators
* can use same decorator more than once on component

The drawbacks are:

* cannot transparently use component's original interface

This drawback also means that
this decorator isn't really a decorator under the Gang of Four definition.
It otherwise looks and acts overwhelmingly like a decorator.

## The "transparent interface" requirement

Let's say the interface we care about decorating is `cost`.
If so, we don't need to also support `origin` method.
Then, the PORO decorator meets our practical needs.

By redefining the scope of "interface" to be
the subset of the object's entire interface that we care about,
we meet the Gang of Four definition.

Consider how many methods are on `Object` in Ruby 1.9.3:

```
> Object.new.methods.size
=> 56
```

An `Object` in Rails has more than double the number of methods:

```
> Object.new.methods.size
=> 118
```

An `ActiveRecord` Object has even more:

```
> User.new.methods.size
=> 366
```

We're not using hundreds of methods on each object,
especially in typical use from a Rails view.

If we used the PORO decorator in a Rails app
to decorate an `ActiveRecord` object,
we're probably reducing the interface by about 300 methods.

In practice, when test-driving a new feature,
I have not found this to be an actual problem.
That's why I start with this decorator.

Next, we add one or two more methods that delegate:

```ruby
def comments
  @component.comments
end

def any?
  @component.any?
end
```

When this feels tedious or repetitive,
the "transparent interface" requirement becomes relevant.

The transparent interface is usually accomplished with `method_missing`
or something from Ruby's `delegate` library such as
`Delegator`, `SimpleDelegator`, `DelegateClass`, or `Forwardable`.

## `method_missing` decorator

This variation is implemented like this:

```ruby
module Decorator
  def initialize(component)
    @component = component
  end

  def method_missing(meth, *args)
    if @component.respond_to?(meth)
      @component.send(meth, *args)
    else
      super
    end
  end

  def respond_to?(meth)
    @component.respond_to?(meth)
  end
end

class Coffee
  def cost
    2
  end

  def origin
    "Colombia"
  end
end

class Milk
  include Decorator

  def cost
    @component.cost + 0.4
  end
end

coffee = Coffee.new
Sugar.new(Milk.new(coffee)).cost   # 2.6
Sugar.new(Sugar.new(coffee)).cost  # 2.4
Sugar.new(Milk.new(coffee)).origin # Colombia
Sugar.new(Milk.new(coffee)).class  # Sugar
```

The benefits are:

* can be wrapped infinitely using Ruby instantiation
* delegates through all decorators
* can use the same decorator more than once on the same component
* transparently uses component's original interface

The drawbacks are:

* uses `method_missing`
* the class of the decorated object is the decorator

Rails inflects (`object.class.name`) for polymorphic relationships,
`form_for`,
and other places,
which can cause `ActiveRecord` errors during test runs.

## `SimpleDelegator` + `super` + `__getobj__` decorator

So, a Rails compromise is this decorator implementation.
I try to use it only as a last resort:

```ruby
class Coffee
  def cost
    2
  end

  def origin
    "Colombia"
  end
end

require 'delegate'

class Decorator < SimpleDelegator
  def class
    __getobj__.class
  end
end

class Milk < Decorator
  def cost
    super + 0.4
  end
end

coffee = Coffee.new
Sugar.new(Milk.new(coffee)).cost   # 2.6
Sugar.new(Sugar.new(coffee)).cost  # 2.4
Milk.new(coffee).origin            # Colombia
Sugar.new(Milk.new(coffee)).class  # Coffee
```

The benefits are:

* can be wrapped infinitely using Ruby instantiation
* delegates through all decorators
* can use same decorator more than once on component
* transparently uses component's original interface
* class is the component

The drawbacks are:

* it redefines `class`

I don't know what problems can result from
using `method_missing` or redefining `class`
but I imagine they manifest in the form of a time-consuming debugging session.

## Plan of action

I start with POROs,
then evolve the object to use `SimpleDelegator` if I need a
transparent interface or the decorated object's `class`
is causing problems for Rails.
