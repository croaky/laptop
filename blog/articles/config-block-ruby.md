# Config Block

Imagine using a third-party library in your Ruby program
and configuring it like this:

```embed
config-block.rb block
```

How might it be implemented?

```embed
config-block.rb module
```

The `config` class method
stores a global `Config` object
in the `Service` module.

Each config setting can be accessed like this:

```embed
config-block.rb access
```
