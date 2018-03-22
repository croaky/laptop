# frozen_string_literal: true

require 'net/http'

class Watson
  API = 'https://gateway.watsonplatform.net/natural-language-classifier/api/v1'

  attr_reader :uri, :username, :password

  def initialize(id:, username:, password:)
    @uri = URI("#{API}/classifiers/#{id}/classify")
    @username = username
    @password = password
  end

  def classify(text)
    uri.query = URI.encode_www_form(text: text)

    Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      request = Net::HTTP::Get.new(uri)
      request.basic_auth(username, password)
      response = http.request(request)

      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)['top_class']
      else
        'dog'
      end
    end
  end
end
