# frozen_string_literal: true

require_relative '../../services/sendgrid'

RSpec.describe Sendgrid, '#deliver' do
  it 'delivers email for given fields' do
    sendgrid = Sendgrid.new(api_key: '123abc')
    stub_sendgrid(
      response_body: '',
      status: 200,
    )

    response_code, response_body = sendgrid.deliver(
      from: 'from@example.com',
      from_name: 'From Name',
      subject: 'RSpec tests',
      text: 'Are useful',
      to: 'to@example.com',
      to_name: 'To Name',
    )

    expect(response_code).to eq 200
    expect(response_body).to eq ''
  end

  it 'returns message, which can contain error details' do
    sendgrid = Sendgrid.new(api_key: '123abc')
    errors_json = %({ "errors": [{ "message": "Something went wrong" }] })
    stub_sendgrid(
      response_body: errors_json,
      status: 400,
    )

    response_code, response_body = sendgrid.deliver(
      from: 'from@example.com',
      from_name: 'From Name',
      subject: 'RSpec tests',
      text: 'Are useful',
      to: 'abademailaddress',
      to_name: 'To Name',
    )

    expect(response_code).to eq 400
    expect(response_body).to eq 'Something went wrong'
  end
end
