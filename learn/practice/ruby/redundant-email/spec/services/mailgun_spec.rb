# frozen_string_literal: true

require_relative '../../services/mailgun'

RSpec.describe Mailgun, '#deliver' do
  it 'delivers email for given fields' do
    domain = 'example.com'
    mailgun = Mailgun.new(domain: domain, api_key: '123abc')
    stub_mailgun(
      domain: domain,
      message: Mailgun::MESSAGE_SUCCESS,
      status: 200,
    )

    response_code, response_body = mailgun.deliver(
      from: 'Dan <dan@example.com>',
      subject: 'RSpec tests',
      text: 'Are useful',
      to: 'Dan <dan@example.com>',
    )

    expect(response_code).to eq 200
    expect(response_body).to eq Mailgun::MESSAGE_SUCCESS
  end

  it 'returns message, which can contain error details' do
    domain = 'example.com'
    mailgun = Mailgun.new(domain: domain, api_key: '123abc')
    msg = "'to' parameter is not a valid address. please check documentation"
    stub_mailgun(
      domain: domain,
      message: msg,
      status: 400,
    )

    response_code, response_body = mailgun.deliver(
      from: 'Dan <dan@example.com>',
      subject: 'RSpec tests',
      text: 'Are useful',
      to: 'Dan <abademailaddress>',
    )

    expect(response_code).to eq 400
    expect(response_body).to eq msg
  end
end
