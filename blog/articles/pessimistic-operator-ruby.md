# Pessimistic Operator

Ruby's pessimistic operator `~>` appears in `Gemfile`s:

```
gem "rails", "~> 3.0.3"
gem "thin",  "~> 1.1"
```

`~> 3.0.3` means that when we `bundle install`,
we'll get the highest-released gem version of `rails`
between the range `>= 3.0.3` and `< 3.1`.

`~> 1.1` means that when you `bundle install`,
we'll get the highest-released gem version of `thin`
between the range `>= 1.1` and `< 2.0`.

Using the pessimistic operator with [Semantic Versioning] by gem authors,
we can achieve better stability in our dependencies.

[Semantic Versioning]: http://semver.org/

Read more [Ruby dependency management guidelines][guidelines].

[guidelines]: https://github.com/thoughtbot/guides/tree/master/best-practices#bundler
