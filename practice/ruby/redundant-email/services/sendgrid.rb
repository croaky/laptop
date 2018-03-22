# frozen_string_literal: true

require 'net/http'
require 'uri'

class Sendgrid
  def initialize(api_key:)
    @api_key = api_key
    @uri = URI.parse('https://api.sendgrid.com/v3/mail/send')
  end

  def deliver(from:, from_name:, to:, to_name:, subject:, text:)
    Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      request = Net::HTTP::Post.new(
        uri.request_uri,
        'Authorization' => "Bearer #{api_key}",
        'Content-Type' => 'application/json',
      )
      request.body = {
        content: [
          {
            type: 'text/plain',
            value: text,
          },
        ],
        from: {
          email: from,
          name: from_name,
        },
        personalizations: [
          {
            to: [
              {
                email: to,
                name: to_name,
              },
            ],
          },
        ],
        subject: subject,
      }.to_json
      response = http.request(request)

      if response.is_a?(Net::HTTPSuccess)
        [200, response.body]
      else
        [
          response.code.to_i,
          JSON
            .parse(response.body)['errors']
            .map { |error| error['message'] }
            .join(', '),
        ]
      end
    end
  end

  private

  attr_reader(
    :api_key,
    :uri,
  )
end
