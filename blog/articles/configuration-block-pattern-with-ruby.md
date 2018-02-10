# Configuration Block Pattern with Ruby

We recently enhanced [Clearance](http://github.com/thoughtbot/clearance) with a
configuration block that could be used in `config/initializers/clearance.rb`.

I liked the way [Airbrake](http://airbrake.io) did it
and wanted to implement the same pattern:

```ruby
Airbrake.configure do |config|
  config.api_key = "your_key_here"
end
```

Here's the implementation:

```ruby
module Clearance
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :mailer_sender

    def initialize
      @mailer_sender = "donotreply@example.com"
    end
  end
end
```

The `configure` class method stores a `Configuration` object inside the
`Clearance` module.

Anything set from the `configure` block is an `attr_accessor` on the
`Configuration` class.

So now `config/initializers/clearance.rb` is possible:

```ruby
Clearance.configure do |config|
  config.mailer_sender = "hello@example.com"
end
```

Each configuration setting can be accessed like this:

```ruby
Clearance.configuration.mailer_sender
```

In the library's tests,
set configuration attributes without worrying about undefining constants:

```ruby
Clearance.configuration.mailer_sender = "updated@example.com"
```
