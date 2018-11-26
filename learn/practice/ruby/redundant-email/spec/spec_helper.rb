# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require_relative '../app'
require 'rack/test'
require 'webmock/rspec'

WebMock.disable_net_connect!(allow_localhost: true)

module SpecHelpers
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def stub_mailgun(domain:, status:, message:)
    stub_request(
      :post,
      "https://api.mailgun.net/v3/#{domain}/messages",
    ).to_return(
      status: status,
      body: %({ "message": "#{message}" }),
    )
  end

  def stub_sendgrid(status:, response_body:)
    stub_request(
      :post,
      'https://api.sendgrid.com/v3/mail/send',
    ).to_return(
      status: status,
      body: response_body,
    )
  end
end

RSpec.configure do |config|
  config.disable_monkey_patching!

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.include SpecHelpers

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.order = :random
  config.shared_context_metadata_behavior = :apply_to_host_groups

  Kernel.srand config.seed
end
