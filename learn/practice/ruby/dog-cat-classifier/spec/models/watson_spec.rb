# frozen_string_literal: true

require_relative '../../app/models/watson'

RSpec.describe Watson, '#classify' do
  it 'classifies based on IBM Watson response' do
    stub_watson_success('cat')
    watson = Watson.new(id: 'test', username: 'test', password: 'test')

    result = watson.classify('6 foot 5, 210 pounds')

    expect(result).to eq 'cat'
  end

  it 'defaults to dog' do
    stub_watson_failure
    watson = Watson.new(id: 'test', username: 'test', password: 'test')

    result = watson.classify('6 foot 5, 210 pounds')

    expect(result).to eq 'dog'
  end

  def stub_watson_success(top_class)
    stub_request(:get, %r{^https:\/\/gateway.watsonplatform.net})
      .to_return(status: 200, body: %({ "top_class": "#{top_class}" }))
  end

  def stub_watson_failure
    stub_request(:get, %r{^https:\/\/gateway.watsonplatform.net})
      .to_return(status: 500)
  end
end
