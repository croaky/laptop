# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'POST /email' do
  it 'delivers email with Mailgun, converts HTML to plain text' do
    body = '<h1>Your Invoice</h1><p>$10</p>'
    stub_mailgun_success(
      body_text: "Your Invoice\n\n$10",
      domain: ENV.fetch('MAILGUN_DOMAIN', 'test'),
      headers: valid_headers,
    )

    post '/email', valid_headers.merge(body: body).to_json

    expect(last_response.status).to eq 200
    expect(last_response.body).to eq 'Queued. Thank you.'
  end

  it 'validates all params are present' do
    post '/email'

    expect(last_response.status).to eq 400
    expect(last_response.body).to eq(
      'body, from, from_name, subject, to, to_name are required fields',
    )
  end

  it 'returns an error message if a problem with Mailgun' do
    error_message = "We're sorry, but something went wrong."
    stub_mailgun(
      domain: ENV.fetch('MAILGUN_DOMAIN', 'test'),
      message: error_message,
      status: 500,
    )

    post '/email', valid_headers.to_json

    expect(last_response.status).to eq 500
    expect(last_response.body).to eq error_message
  end
end

def valid_headers
  {
    from: 'support@example.com',
    from_name: 'Service',
    subject: 'Invoice from Service',
    to: 'fake@example.com',
    to_name: 'Mr. Fake',
  }
end

def stub_mailgun_success(body_text:, domain:, headers:)
  stub_request(
    :post,
    "https://api.mailgun.net/v3/#{domain}/messages",
  ).with(
    body: {
      'from' => "#{headers[:from_name]} <#{headers[:from]}>",
      'subject' => headers[:subject],
      'text' => body_text,
      'to' => "#{headers[:to_name]} <#{headers[:to]}>",
    },
  ).to_return(
    status: 200,
    body: %({ "message": "Queued. Thank you." }),
  )
end
