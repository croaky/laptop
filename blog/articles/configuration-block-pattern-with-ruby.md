# Configuration Block Pattern with Ruby

Imagine using a third-party library in your Ruby program
and configuring it like this:

```ruby
Service.configure do |config|
  config.api_key = "your_key_here"
  config.from = "team@example.com"
end
```

How might it be implemented?

```ruby
module Service
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :api_key

    def initialize
      @from = "default@example.com"
    end
  end
end
```

The `configure` class method
stores a `Configuration` object
in the `Service` module.

Anything set from the `configure` block
is an `attr_accessor` on the `Configuration` class.

Each configuration setting can be accessed like this:

```ruby
Service.configuration.api_key
Service.configuration.api_key = 'new-key'
```
