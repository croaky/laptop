# frozen_string_literal: true

def expect
  unless yield
    exit 1
  end
end

# begindoc: module
module Service
  def self.config
    @config ||= Config.new
  end

  def self.configure
    yield config
  end

  class Config
    attr_accessor :api_key, :from

    def initialize
      @api_key = ''
      @from = 'default@example.com'
    end
  end
end
# enddoc: module

expect { Service.config.api_key == '' }
expect { Service.config.from == 'default@example.com' }

# begindoc: block
Service.configure do |config|
  config.api_key = 'your_key_here'
  config.from = 'team@example.com'
end
# enddoc: block

expect { Service.config.api_key == 'your_key_here' }
expect { Service.config.from == 'team@example.com' }

# begindoc: access
Service.config.api_key
# enddoc: access
