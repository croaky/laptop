# frozen_string_literal: true

require 'dotenv'
require 'html_to_plain_text'
require 'sinatra'

Dotenv.load

require_relative 'services/mailgun'
require_relative 'services/sendgrid'

post '/email' do
  attributes = parse(request)

  if attributes && valid?(attributes)
    if mailgun?
      response_code, response_body = deliver_with_mailgun(attributes)
    else
      response_code, response_body = deliver_with_sendgrid(attributes)
    end

    status response_code
    response_body
  else
    status 400
    REQUIRED_ATTRIBUTES.join(', ') + ' are required fields'
  end
end

def parse(request)
  json = JSON.parse(request.body.read)
  json['body'] = HtmlToPlainText.plain_text(json['body'])
  json
rescue StandardError
  nil
end

def valid?(attributes)
  REQUIRED_ATTRIBUTES.all? { |attr| attributes.include?(attr) }
end

REQUIRED_ATTRIBUTES = ['body', 'from', 'from_name', 'subject', 'to', 'to_name'].freeze

def mailgun?
  ENV.fetch('EMAIL_SERVICE', 'mailgun') == 'mailgun'
end

def deliver_with_mailgun(attributes)
  Mailgun.new(
    api_key: ENV.fetch('MAILGUN_API_KEY', 'test'),
    domain: ENV.fetch('MAILGUN_DOMAIN', 'test'),
  ).deliver(
    from: "#{attributes['from_name']} <#{attributes['from']}>",
    subject: attributes['subject'],
    text: attributes['body'],
    to: "#{attributes['to_name']} <#{attributes['to']}>",
  )
end

def deliver_with_sendgrid(attributes)
  Sendgrid.new(
    api_key: ENV.fetch('SENDGRID_API_KEY', 'test'),
  ).deliver(
    from: attributes['from'],
    from_name: attributes['from_name'],
    subject: attributes['subject'],
    text: attributes['body'],
    to: attributes['to'],
    to_name: attributes['to_name'],
  )
end
