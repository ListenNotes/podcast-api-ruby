# Podcast API Ruby Library

[![Build Status](https://travis-ci.com/ListenNotes/podcast-api-ruby.svg?branch=main)](https://travis-ci.com/ListenNotes/podcast-api-ruby)


The Podcast API Ruby library provides convenient access to the [Listen Notes Podcast API](https://www.listennotes.com/api/) from
applications written in Ruby.

Simple and no-nonsense podcast search & directory API. Search the meta data of all podcasts and episodes by people, places, or topics.

<a href="https://www.listennotes.com/api/"><img src="https://raw.githubusercontent.com/ListenNotes/ListenApiDemo/master/web/src/powered_by_listennotes.png" width="300" /></a>

## Documentation

See the [Listen Notes Podcast API docs](https://www.listennotes.com/api/docs/).


## Installation

Install the package with:
```sh
gem install podcast_api
```


### Requirements

- Ruby 2.3+

## Usage

The library needs to be configured with your account's API key which is
available in your [Listen API Dashboard](https://www.listennotes.com/api/dashboard/#apps). Set `api_key` to its
value:

```ruby

require "podcast_api"

api_key = ENV["LISTEN_API_KEY"]
client = PodcastApi::Client.new(api_key: api_key)

begin
    response = client.search(q: 'startup', type: 'episode')
    puts JSON.parse(response.body)
rescue PodcastApi::AuthenticationError
    puts 'Wrong api key'
rescue PodcastApi::InvalidRequestError
    puts 'Client side errors, e.g., wrong parameters'
rescue PodcastApi::NotFoundError
    puts 'Not found'
rescue PodcastApi::RateLimitError
    puts 'Reached quota limit'
rescue PodcastApi::APIConnectionError
    puts 'Failed to connect to Listen API servers'
rescue PodcastApi::PodcastApiError
    puts 'Server side errors'
else
    puts "Free Quota per month: #{response.headers['X-ListenAPI-FreeQuota']}"
    puts "Usage this month: #{response.headers['X-ListenAPI-Usage']}"
    puts "Next billing date: #{response.headers['X-Listenapi-NextBillingDate']}"
end
```

If `api_key` is nil, then we'll connect to a [mock server](https://www.listennotes.com/api/tutorials/#faq0) that returns fake data for testing purposes.

You can see all available API endpoints and parameters on the API Docs page at [listennotes.com/api/docs/](https://www.listennotes.com/api/docs/).

### Handling exceptions

Unsuccessful requests raise exceptions. The class of the exception will reflect
the sort of error that occurred.

All exception classes can be found in [this file](https://github.com/ListenNotes/podcast-api-ruby/blob/main/lib/errors.rb).

And you can see some sample code [here](https://github.com/ListenNotes/podcast-api-ruby/blob/main/examples/sample.rb).
