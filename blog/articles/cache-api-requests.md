# Cache API Requests

Caching HTTP GET requests can improve performance
and help avoid hitting rate limits.

```ruby
service = RemoteService.new
data = service.get("https://example.com/endpoint")
```

The first time this code runs,
an HTTP request will be made.
The request URL and response body
will be saved to a database.

When it runs again within the external service's cache policy,
the HTTP request will not be made.
The cached response body will be served by the database.

```ruby
require "json"
require "net/http"
require "openssl"
require "uri"

class RemoteService
  CACHE_POLICY = lambda { 30.days.ago }

  def get(url)
    req = ApiRequest.find(url)

    unless req.cached?(CACHE_POLICY.call)
      body = get_and_parse(url)

      if body
        req.update(response_body: body)
      end
    end

    req.response_body
  end

  private

  def get_and_parse(url)
    uri = URI(url)
    connection = Net::HTTP.new(uri.host, uri.port)
    connection.use_ssl = true
    connection.verify_mode = OpenSSL::SSL::VERIFY_PEER
    request = Net::HTTP::Get.new(uri)
    response = connection.request(request)

    if response.is_a?(Net::HTTPSuccess)
      JSON.parse(response.body)
    end
  end
end

class ApiRequest < ApplicationRecord
  validates :hashed_url, presence: true, uniqueness: true

  def self.find(url)
    hashed_url = Digest::MD5.hexdigest(url)
    find_or_initialize_by(hashed_url: hashed_url)
  end

  def cached?(expired_at)
    return false if new_record?
    expired_at < updated_at
  end
end

class CreateApiRequests < ActiveRecord::Migration
  def change
    create_table :api_requests do |t|
      t.timestamps null: false
      t.string :hashed_url, null: false
      t.jsonb :response_body, default: {}, null: false
    end

    add_index :api_requests, :hashed_url, unique: true
    add_index :api_requests, :response_body, using: :gin
  end
end
```

The `response_body` field contains the response JSON
using [Postgres' JSONB column][jsonb].

[jsonb]: https://www.postgresql.org/docs/9.6/static/functions-json.html

The index improves performance of future lookups
and enforces uniqueness of the URL.

The URL is hashed in case sensitive data is included in query params.
