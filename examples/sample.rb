# frozen_string_literal: true

require 'podcast_api'

# No API key uses the stateless public mock server.
client = PodcastApi::Client.new(api_key: ENV['LISTEN_API_KEY'])
response = client.search(q: 'startup', type: 'episode')
puts response.parsed_response
puts "Usage this month: #{response.headers['X-ListenAPI-Usage']}"
