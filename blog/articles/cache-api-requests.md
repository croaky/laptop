# Cache API Requests

When making requests to an external service's API,
some requests will frequently occur with the same parameters
and return the same result.
If we cache our request or response, we can reduce HTTP requests,
which can improve performance and avoid hitting rate limits.

```ruby
require "uri"
require "net/http"
require "openssl"

class ExternalService
  class Error < StandardError; end

  CACHE_POLICY = lambda { 30.days.ago }

  def cached_get(url)
    api_request = ApiRequest.find(url)

    unless api_request.cached_since?(CACHE_POLICY.call)
      api_request.update(response_body: get(url))
    end
  end

  private

  def get(url)
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(uri)
    response = http.request(request)

    if response.is_a?(Net::HTTPSuccess)
      JSON.parse(response.body)
    else
      raise Error, response.body
    end
  end
end
```

The first time this code runs,
`ApiRequest` will save the URL to the database
and the block will be executed.

Whenever this runs again,
as long as it is within the external service's 30 day cache policy,
the block won't be executed and expensive work will be avoided.

Here's the database migration:

```ruby
class CreateApiRequests < ActiveRecord::Migration
  def change
    create_table :api_requests do |t|
      t.timestamps null: false
      t.string :token, null: false
      t.jsonb :response_body, default: {}, null: false
    end

    add_index :api_requests, :token, unique: true
    add_index :api_requests, :response_body, using: :gin
  end
end
```

The `response_body` field can optionally be used to save the response JSON
using [Postgres' JSONB column][jsonb],
which has excellent query abilities.

[jsonb]: https://www.postgresql.org/docs/9.6/static/functions-json.html

The index improves performance of future lookups
and enforces uniqueness of the URL.

Here's the `ApiRequest` model:

```ruby
class ApiRequest < ApplicationRecord
  validates :token, presence: true, uniqueness: true

  def self.find(url)
    token = Digest::MD5.hexdigest(url)
    find_or_initialize_by(token: token)
  end

  def cached_since?(expired_at)
    expired_at < updated_at
  end
end
```

This model is generic enough to be used with multiple external services.

The URL is hashed in case credentials such as API keys
are accidentally sent in as query params.

## Summary

Cache `GET` requests to an external API
to improve performance and avoid hitting rate limits.
