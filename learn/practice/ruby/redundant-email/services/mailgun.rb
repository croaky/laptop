# frozen_string_literal: true

require 'net/http'
require 'uri'

class Mailgun
  MESSAGE_SUCCESS = 'Queued. Thank you.'
  STANDARD_USERNAME = 'api'

  def initialize(domain:, api_key:)
    @uri = URI.parse("https://api.mailgun.net/v3/#{domain}/messages")
    @username = STANDARD_USERNAME
    @password = "key-#{api_key}"
  end

  def deliver(from:, to:, subject:, text:)
    Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      request = Net::HTTP::Post.new(uri.request_uri)
      request.basic_auth(username, password)
      request.set_form_data(
        'from' => from,
        'subject' => subject,
        'text' => text,
        'to' => to,
      )
      response = http.request(request)
      [response.code.to_i, JSON.parse(response.body)['message']]
    end
  end

  private

  attr_reader(
    :password,
    :uri,
    :username,
  )
end
