# Podcast API Ruby Library

[![Ruby CI](https://github.com/ListenNotes/podcast-api-ruby/actions/workflows/ruby.yml/badge.svg)](https://github.com/ListenNotes/podcast-api-ruby/actions/workflows/ruby.yml) [![Gem](https://img.shields.io/gem/v/podcast_api)](https://rubygems.org/gems/podcast_api)


The Podcast API Ruby library provides convenient access to the [Listen Notes Podcast API](https://www.listennotes.com/podcast-api/) from
applications written in Ruby.

Simple and no-nonsense podcast search & directory API. Search the meta data of all podcasts and episodes by people, places, or topics. It's the same API that powers the [best podcast search engine Listen Notes](https://www.listennotes.com/).

If you have any questions, please contact [hello@listennotes.com](hello@listennotes.com?subject=Questions+about+the+Ruby+SDK+of+Listen+API)

<a href="https://www.listennotes.com/podcast-api/"><img src="https://raw.githubusercontent.com/ListenNotes/ListenApiDemo/master/web/src/powered_by_listennotes.png" width="300" /></a>



**Table of Contents**

- [Podcast API Ruby Library](#podcast-api-ruby-library)
  - [Installation](#installation)
    - [Requirements](#requirements)
  - [Usage](#usage)
    - [Handling exceptions](#handling-exceptions)
  - [API Reference](#api-reference)
  - [Development](#development)

<!-- BEGIN GENERATED METHOD INDEX -->

- [`search`](#search) — `GET /search`
- [`typeahead`](#typeahead) — `GET /typeahead`
- [`search_episode_titles`](#search_episode_titles) — `GET /search_episode_titles`
- [`spellcheck`](#spellcheck) — `GET /spellcheck`
- [`fetch_related_searches`](#fetch_related_searches) — `GET /related_searches`
- [`fetch_trending_searches`](#fetch_trending_searches) — `GET /trending_searches`
- [`fetch_best_podcasts`](#fetch_best_podcasts) — `GET /best_podcasts`
- [`fetch_podcast_by_id`](#fetch_podcast_by_id) — `GET /podcasts/{id}`
- [`delete_podcast`](#delete_podcast) — `DELETE /podcasts/{id}`
- [`fetch_episode_by_id`](#fetch_episode_by_id) — `GET /episodes/{id}`
- [`batch_fetch_episodes`](#batch_fetch_episodes) — `POST /episodes`
- [`batch_fetch_podcasts`](#batch_fetch_podcasts) — `POST /podcasts`
- [`fetch_curated_podcasts_list_by_id`](#fetch_curated_podcasts_list_by_id) — `GET /curated_podcasts/{id}`
- [`fetch_podcast_genres`](#fetch_podcast_genres) — `GET /genres`
- [`fetch_podcast_regions`](#fetch_podcast_regions) — `GET /regions`
- [`fetch_podcast_languages`](#fetch_podcast_languages) — `GET /languages`
- [`just_listen`](#just_listen) — `GET /just_listen`
- [`fetch_curated_podcasts_lists`](#fetch_curated_podcasts_lists) — `GET /curated_podcasts`
- [`fetch_recommendations_for_podcast`](#fetch_recommendations_for_podcast) — `GET /podcasts/{id}/recommendations`
- [`fetch_recommendations_for_episode`](#fetch_recommendations_for_episode) — `GET /episodes/{id}/recommendations`
- [`submit_podcast`](#submit_podcast) — `POST /podcasts/submit`
- [`fetch_playlist_by_id`](#fetch_playlist_by_id) — `GET /playlists/{id}`
- [`fetch_my_playlists`](#fetch_my_playlists) — `GET /playlists`
- [`fetch_audience_for_podcast`](#fetch_audience_for_podcast) — `GET /podcasts/{id}/audience`
- [`fetch_podcasts_by_domain`](#fetch_podcasts_by_domain) — `GET /podcasts/domains/{domain_name}`
- [`create_playlist`](#create_playlist) — `POST /playlists`
- [`update_playlist`](#update_playlist) — `PUT /playlists/{id}`
- [`add_playlist_item`](#add_playlist_item) — `POST /playlists/{id}/items`
- [`delete_playlist_item`](#delete_playlist_item) — `DELETE /playlists/{id}/items/{item_id}`
- [`update_playlist_item_notes`](#update_playlist_item_notes) — `PUT /playlists/{id}/items/{item_id}`

<!-- END GENERATED METHOD INDEX -->

## Installation

Install [the official Ruby Gem](https://rubygems.org/gems/podcast_api) of the Listen Notes Podcast API:
```sh
gem install podcast_api
```


### Requirements

- Ruby 3.3+

## Usage

The library needs to be configured with your account's API key which is
available in your [Listen API Dashboard](https://www.listennotes.com/podcast-api/dashboard/#apps). Set `api_key` to its
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
    puts 'Reached quota limit or rate limit'
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

If `api_key` is nil or empty, then we'll connect to a [mock server](https://help.listennotes.com/en/articles/5224500-how-to-test-the-podcast-api-without-an-api-key) that returns fake data for testing purposes.


### Handling exceptions

Unsuccessful requests raise exceptions. The class of the exception will reflect
the sort of error that occurred.

| Exception Class  | Description |
| ------------- | ------------- |
|  AuthenticationError | wrong api key or your account is suspended  |
| PermissionDeniedError | this API account cannot modify the requested resource |
| APIConnectionError  | fail to connect to API servers  |
| InvalidRequestError  | something wrong on your end (client side errors), e.g., missing required parameters  |
| RateLimitError  | for FREE plan, exceeding the quota limit; or for all plans, sending too many requests too fast and exceeding the rate limit  |
| NotFoundError  | endpoint not exist, or podcast / episode not exist  |
| PodcastApiError  | something wrong on our end (unexpected server errors)  |

All exception classes can be found in [this file](https://github.com/ListenNotes/podcast-api-ruby/blob/main/lib/errors.rb).

And you can see some sample code [here](https://github.com/ListenNotes/podcast-api-ruby/blob/main/examples/sample.rb#L9).




## Upgrading to 3.0.0

Ruby 3.3 or newer is required. Existing method names, keyword arguments, and
`HTTParty::Response` results are preserved. Five playlist write methods are now
available. Successful `201` responses are accepted, and `403` raises
`PodcastApi::PermissionDeniedError`. API errors include the server's message and
expose the original response as `error.response`.

Requests use a 30-second timeout for each connection/read/write operation. Set
`timeout:` when constructing a client to change it. Redirects and automatic
connection retries are disabled, so a failed write is never silently replayed.
The default User-Agent is `podcast-api-ruby 3.0.0`.

## Development

Install Ruby 3.3+ and Bundler, then run from this repository:

```sh
gem install bundler -v 4.0.20
bundle install
bundle exec rake test           # Offline; unexpected network requests fail
bundle exec rake integration    # Live, stateless public mock only; no API key
bundle exec rake build          # Produces pkg/podcast_api-3.0.0.gem
bundle exec ruby examples/sample.rb
```

CI runs offline tests on Ruby 3.3 and 4.0, with a separate public-mock integration
job. Development dependencies are pinned in `Gemfile` and `Gemfile.lock`.
The gem only needs HTTParty at runtime.

Endpoint methods, `lib/api-contract.json`, and the marked README sections are
generated from the Listen Notes monorepo's canonical OpenAPI specification and
`devtools/api-sdks/registry/ruby.json`. Do not edit those generated sections by
hand. Run `sync.py ruby` there to regenerate, or `sync.py ruby --check` to
check for stale output. This standalone repository can run all tests and build
the gem without the monorepo, a database, or production credentials.

## API Reference

<!-- BEGIN GENERATED API REFERENCE -->

Each method accepts keyword arguments and returns an `HTTParty::Response`. Set `LISTEN_API_KEY` for real API requests; without it, these examples use the stateless mock server.

### search

Full-text search

`GET /search`

Full-text search on episodes, podcasts, or curated lists of podcasts.
Use the `offset` parameter to paginate through search results.
The FREE plan allows to see up to 30 search results (or `offset` < 30) per query.
The PRO plan allows to see up to 300 search results (or `offset` < 300) per query.
The ENTERPRISE plan allows to see up to 10,000 search results (or `offset` < 10000) per query.

```ruby
require "podcast_api"

client = PodcastApi::Client.new(api_key: ENV["LISTEN_API_KEY"])
response = client.search(**{
  'q' => 'star wars',
  'sort_by_date' => 0,
  'type' => 'episode',
  'offset' => 0,
  'len_min' => 10,
  'len_max' => 30,
  'genre_ids' => '68,82',
  'published_before' => 1580172454000,
  'published_after' => 0,
  'only_in' => 'title,description',
  'language' => 'English',
  'region' => '',
  'safe_mode' => 0,
  'unique_podcasts' => 0,
  'interviews_only' => 0,
  'sponsored_only' => 0,
  'page_size' => 10
})
puts response.parsed_response
```

[Full API documentation](https://www.listennotes.com/api/docs/#get-api-v2-search)

### typeahead

Typeahead search

`GET /typeahead`

Suggest search terms, podcast genres, and podcasts.

```ruby
require "podcast_api"

client = PodcastApi::Client.new(api_key: ENV["LISTEN_API_KEY"])
response = client.typeahead(**{
  'q' => 'star wars',
  'show_podcasts' => 1,
  'show_genres' => 1,
  'safe_mode' => 0
})
puts response.parsed_response
```

[Full API documentation](https://www.listennotes.com/api/docs/#get-api-v2-typeahead)

### search_episode_titles

Find individual episodes by searching for their titles

`GET /search_episode_titles`

Conduct targeted searches for individual episodes by title and refine results using the podcast id such as
Listen Notes Podcast ID, Apple Podcasts ID, Spotify ID, or RSS feed URL.
This endpoint is specially designed to streamline the import of specific episodes from platforms
like Apple Podcasts and Spotify into your application.
Compared to the GET /search endpoint, which performs full-text searches across multiple fields,
this endpoint focuses solely on episode titles for enhanced accuracy and performance.

```ruby
require "podcast_api"

client = PodcastApi::Client.new(api_key: ENV["LISTEN_API_KEY"])
response = client.search_episode_titles(**{
  'q' => 'Jerusalem Demsas on The Dispossessed'
})
puts response.parsed_response
```

[Full API documentation](https://www.listennotes.com/api/docs/#get-api-v2-search_episode_titles)

### spellcheck

Spell check on a search term

`GET /spellcheck`

Suggest a list of words that correct the spelling errors of a search term. This endpoint is available only in the PRO/ENTERPRISE plan.

```ruby
require "podcast_api"

client = PodcastApi::Client.new(api_key: ENV["LISTEN_API_KEY"])
response = client.spellcheck(**{
  'q' => 'microsft stock'
})
puts response.parsed_response
```

[Full API documentation](https://www.listennotes.com/api/docs/#get-api-v2-spellcheck)

### fetch_related_searches

Fetch related search terms

`GET /related_searches`

Suggest related search terms. The results are more comprehensive than from `GET /typeahead`. This endpoint is available only in the PRO/ENTERPRISE plan.

```ruby
require "podcast_api"

client = PodcastApi::Client.new(api_key: ENV["LISTEN_API_KEY"])
response = client.fetch_related_searches(**{
  'q' => 'evergrande'
})
puts response.parsed_response
```

[Full API documentation](https://www.listennotes.com/api/docs/#get-api-v2-related_searches)

### fetch_trending_searches

Fetch trending search terms

`GET /trending_searches`

Fetch up to 10 most recent trending search terms on the Listen Notes platform.

```ruby
require "podcast_api"

client = PodcastApi::Client.new(api_key: ENV["LISTEN_API_KEY"])
response = client.fetch_trending_searches()
puts response.parsed_response
```

[Full API documentation](https://www.listennotes.com/api/docs/#get-api-v2-trending_searches)

### fetch_best_podcasts

Fetch a list of best podcasts by genre

`GET /best_podcasts`

Get a list of curated best podcasts by genre,
which are curated by Listen Notes staffs based on various signals from the Internet, e.g.,
top charts on other podcast platforms, recommendations from mainstream media,
user activities on listennotes.com...
You can get the genre ids from `GET /genres` endpoint.
This endpoint returns same data as https://www.listennotes.com/best-podcasts/

```ruby
require "podcast_api"

client = PodcastApi::Client.new(api_key: ENV["LISTEN_API_KEY"])
response = client.fetch_best_podcasts(**{
  'genre_id' => 93,
  'page' => 2,
  'region' => 'us',
  'sort' => 'listen_score',
  'safe_mode' => 0
})
puts response.parsed_response
```

[Full API documentation](https://www.listennotes.com/api/docs/#get-api-v2-best_podcasts)

### fetch_podcast_by_id

Fetch detailed meta data and episodes for a podcast by id

`GET /podcasts/{id}`

Fetch detailed meta data and episodes for a specific podcast (up to 10 episodes each time).
You can use the **next_episode_pub_date** parameter to do pagination and fetch more episodes.
During pagination with **next_episode_pub_date**, an empty **episodes** array in the response signals that no more episodes are available.

```ruby
require "podcast_api"

client = PodcastApi::Client.new(api_key: ENV["LISTEN_API_KEY"])
response = client.fetch_podcast_by_id(**{
  'id' => '4d3fe717742d4963a85562e9f84d8c79',
  'next_episode_pub_date' => 1479154463000,
  'sort' => 'recent_first'
})
puts response.parsed_response
```

[Full API documentation](https://www.listennotes.com/api/docs/#get-api-v2-podcasts-id)

### delete_podcast

Request to delete a podcast

`DELETE /podcasts/{id}`

Podcast hosting services can use this endpoint to streamline the process of podcast deletion on behave of their users (podcasters). We will review the deletion request within 12 hours. If the podcast is already deleted, the "status" field in the response will be "deleted". Otherwise, the status field will be "in review". If you want to get a notification once the podcast is deleted, you can configure a webhook url in the dashboard: listennotes.com/api/dashboard/#webhooks

```ruby
require "podcast_api"

client = PodcastApi::Client.new(api_key: ENV["LISTEN_API_KEY"])
response = client.delete_podcast(**{
  'id' => '4d3fe717742d4963a85562e9f84d8c79',
  'reason' => 'the podcaster wants to delete it'
})
puts response.parsed_response
```

[Full API documentation](https://www.listennotes.com/api/docs/#delete-api-v2-podcasts-id)

### fetch_episode_by_id

Fetch detailed meta data for an episode by id

`GET /episodes/{id}`

Fetch detailed meta data for a specific episode.

```ruby
require "podcast_api"

client = PodcastApi::Client.new(api_key: ENV["LISTEN_API_KEY"])
response = client.fetch_episode_by_id(**{
  'id' => '6b6d65930c5a4f71b254465871fed370',
  'show_transcript' => 1
})
puts response.parsed_response
```

[Full API documentation](https://www.listennotes.com/api/docs/#get-api-v2-episodes-id)

### batch_fetch_episodes

Batch fetch basic meta data for episodes

`POST /episodes`

Batch fetch basic meta data for up to 10 episodes. This endpoint could be used to implement custom playlists for individual episodes. For detailed meta data of an individual episode, you need to use `GET /episodes/{id}`. This endpoint is available only in the PRO/ENTERPRISE plan.

```ruby
require "podcast_api"

client = PodcastApi::Client.new(api_key: ENV["LISTEN_API_KEY"])
response = client.batch_fetch_episodes(**{
  'ids' => 'c577d55b2b2b483c969fae3ceb58e362,0f34a9099579490993eec9e8c8cebb82'
})
puts response.parsed_response
```

[Full API documentation](https://www.listennotes.com/api/docs/#post-api-v2-episodes)

### batch_fetch_podcasts

Batch fetch basic meta data for podcasts

`POST /podcasts`

Batch fetch basic meta data for up to 10 podcasts.
This endpoint could be used to build something like OPML import,
allowing users to import a bunch of podcasts via rss urls.
For detailed meta data (including episodes) of an individual podcast, you need to use `GET /podcasts/{id}`. This endpoint is available only in the PRO/ENTERPRISE plan.

```ruby
require "podcast_api"

client = PodcastApi::Client.new(api_key: ENV["LISTEN_API_KEY"])
response = client.batch_fetch_podcasts(**{
  'ids' => '3302bc71139541baa46ecb27dbf6071a,68faf62be97149c280ebcc25178aa731,37589a3e121e40debe4cef3d9638932a,9cf19c590ff0484d97b18b329fed0c6a',
  'rsses' => 'https://rss.art19.com/recode-decode,https://rss.art19.com/the-daily,https://www.npr.org/rss/podcast.php?id=510331,https://www.npr.org/rss/podcast.php?id=510331',
  'itunes_ids' => '1457514703,1386234384,659155419',
  'spotify_ids' => '3DDfEsKDIDrTlnPOiG4ZF4,4qDNe5Gvl1XxdLinUGEXrC,23NZCM4ik6o3UYkM473Itz',
  'show_latest_episodes' => 1,
  'next_episode_pub_date' => 1557394247000
})
puts response.parsed_response
```

[Full API documentation](https://www.listennotes.com/api/docs/#post-api-v2-podcasts)

### fetch_curated_podcasts_list_by_id

Fetch a curated list of podcasts by id

`GET /curated_podcasts/{id}`

Get detailed meta data of all podcasts in a specific curated list.
This endpoint returns same data as https://www.listennotes.com/curated-podcasts/

```ruby
require "podcast_api"

client = PodcastApi::Client.new(api_key: ENV["LISTEN_API_KEY"])
response = client.fetch_curated_podcasts_list_by_id(**{
  'id' => 'SDFKduyJ47r'
})
puts response.parsed_response
```

[Full API documentation](https://www.listennotes.com/api/docs/#get-api-v2-curated_podcasts-id)

### fetch_podcast_genres

Fetch a list of podcast genres

`GET /genres`

Get a list of podcast genres that are supported in Listen Notes.
The genre id can be passed to other endpoints as a parameter to get podcasts in a specific genre,
e.g., `GET /best_podcasts`, `GET /search`...
You may want to cache the list of genres on the client side.

```ruby
require "podcast_api"

client = PodcastApi::Client.new(api_key: ENV["LISTEN_API_KEY"])
response = client.fetch_podcast_genres(**{
  'top_level_only' => 1
})
puts response.parsed_response
```

[Full API documentation](https://www.listennotes.com/api/docs/#get-api-v2-genres)

### fetch_podcast_regions

Fetch a list of supported countries/regions for best podcasts

`GET /regions`

It returns a dictionary of country codes (e.g., us, gb...) & country names (United States, United Kingdom...). The country code is used in the query parameter **region** of `GET /best_podcasts`.

```ruby
require "podcast_api"

client = PodcastApi::Client.new(api_key: ENV["LISTEN_API_KEY"])
response = client.fetch_podcast_regions()
puts response.parsed_response
```

[Full API documentation](https://www.listennotes.com/api/docs/#get-api-v2-regions)

### fetch_podcast_languages

Fetch a list of supported languages for podcasts

`GET /languages`

Get a list of languages that are supported in Listen Notes database. You can use the language string as query parameter in `GET /search`.

```ruby
require "podcast_api"

client = PodcastApi::Client.new(api_key: ENV["LISTEN_API_KEY"])
response = client.fetch_podcast_languages()
puts response.parsed_response
```

[Full API documentation](https://www.listennotes.com/api/docs/#get-api-v2-languages)

### just_listen

Fetch a random podcast episode

`GET /just_listen`

Recently published episodes are more likely to be fetched. Good luck!

```ruby
require "podcast_api"

client = PodcastApi::Client.new(api_key: ENV["LISTEN_API_KEY"])
response = client.just_listen()
puts response.parsed_response
```

[Full API documentation](https://www.listennotes.com/api/docs/#get-api-v2-just_listen)

### fetch_curated_podcasts_lists

Fetch curated lists of podcasts

`GET /curated_podcasts`

A bunch of curated lists from online media. For each list, you'll get basic info of up to 5 podcasts. To get detailed meta data of all podcasts in a specific list, you need to use `GET /curated_podcasts/{id}`. We add new curated lists to the database on a daily basis.

```ruby
require "podcast_api"

client = PodcastApi::Client.new(api_key: ENV["LISTEN_API_KEY"])
response = client.fetch_curated_podcasts_lists(**{
  'page' => 2
})
puts response.parsed_response
```

[Full API documentation](https://www.listennotes.com/api/docs/#get-api-v2-curated_podcasts)

### fetch_recommendations_for_podcast

Fetch recommendations for a podcast

`GET /podcasts/{id}/recommendations`

Fetch up to 8 podcast recommendations based on the given podcast id.

```ruby
require "podcast_api"

client = PodcastApi::Client.new(api_key: ENV["LISTEN_API_KEY"])
response = client.fetch_recommendations_for_podcast(**{
  'id' => '25212ac3c53240a880dd5032e547047b',
  'safe_mode' => 0
})
puts response.parsed_response
```

[Full API documentation](https://www.listennotes.com/api/docs/#get-api-v2-podcasts-id-recommendations)

### fetch_recommendations_for_episode

Fetch recommendations for an episode

`GET /episodes/{id}/recommendations`

Fetch up to 8 episode recommendations based on the given episode id.

```ruby
require "podcast_api"

client = PodcastApi::Client.new(api_key: ENV["LISTEN_API_KEY"])
response = client.fetch_recommendations_for_episode(**{
  'id' => '254444fa6cf64a43a95292a70eb6869b',
  'safe_mode' => 0
})
puts response.parsed_response
```

[Full API documentation](https://www.listennotes.com/api/docs/#get-api-v2-episodes-id-recommendations)

### submit_podcast

Submit a podcast to Listen Notes database

`POST /podcasts/submit`

Podcast hosting services can use this endpoint to help your users directly submit a new podcast to Listen Notes database. If the podcast doesn't exist in the database, "status" in the response will be "in review", and we'll review it within 12 hours. If the podcast exists, "status" in the response will be "found". If this submission is rejected, "status" in the response will be "rejected". You can use `POST /podcasts` to check if multiple podcasts exist in the database. If you want to get a notification once the podcast is accepted, you can either specify the "email" parameter or configure a webhook url in the dashboard: listennotes.com/api/dashboard/#webhooks

```ruby
require "podcast_api"

client = PodcastApi::Client.new(api_key: ENV["LISTEN_API_KEY"])
response = client.submit_podcast(**{
  'rss' => 'https://feeds.megaphone.fm/committed',
  'email' => 'hello@example.com'
})
puts response.parsed_response
```

[Full API documentation](https://www.listennotes.com/api/docs/#post-api-v2-podcasts-submit)

### fetch_playlist_by_id

Fetch a playlist's info and items (i.e., episodes or podcasts).

`GET /playlists/{id}`

A playlist can contain both episodes and podcasts, shown in separate views,
just like playlists created via listennotes.com/listen/.
This endpoint fetches items from the saved default view unless **type** is specified.
The response type and listennotes_url describe the selected view.
You can use the **last_pub_date_ms** parameter to do pagination and fetch more items.
A playlist can be **public** (discoverable on ListenNotes.com),
**unlisted** (accessible to anyone who knows the playlist id),
or **private** (accessible when the API admin has active playlist membership).
Public and unlisted playlists can also be fetched by ID regardless of their owner.

```ruby
require "podcast_api"

client = PodcastApi::Client.new(api_key: ENV["LISTEN_API_KEY"])
response = client.fetch_playlist_by_id(**{
  'id' => 'm1pe7z60bsw',
  'type' => 'episode_list',
  'last_timestamp_ms' => 0,
  'sort' => 'recent_added_first'
})
puts response.parsed_response
```

[Full API documentation](https://www.listennotes.com/api/docs/#get-api-v2-playlists-id)

### fetch_my_playlists

Fetch a list of your playlists.

`GET /playlists`

This endpoint lists playlists with an active membership for the API admin, including playlists they created or joined.
Each playlist includes its saved default **type** and a **listennotes_url** for that view.
You can use the **page** parameter to do pagination and fetch more playlists.

```ruby
require "podcast_api"

client = PodcastApi::Client.new(api_key: ENV["LISTEN_API_KEY"])
response = client.fetch_my_playlists(**{
  'sort' => 'recent_added_first',
  'page' => 1
})
puts response.parsed_response
```

[Full API documentation](https://www.listennotes.com/api/docs/#get-api-v2-playlists)

### fetch_audience_for_podcast

Fetch audience demographics for a podcast

`GET /podcasts/{id}/audience`

Fetch audience demographics for a podcast - 1) directly measured on the Listen Notes platform; 2) only supports audience breakdown by regions for now; 3) not every podcast has data.

```ruby
require "podcast_api"

client = PodcastApi::Client.new(api_key: ENV["LISTEN_API_KEY"])
response = client.fetch_audience_for_podcast(**{
  'id' => '25212ac3c53240a880dd5032e547047b'
})
puts response.parsed_response
```

[Full API documentation](https://www.listennotes.com/api/docs/#get-api-v2-podcasts-id-audience)

### fetch_podcasts_by_domain

Fetch podcasts by a publisher's domain name

`GET /podcasts/domains/{domain_name}`

Fetch podcasts by a publisher's domain name, e.g., nytimes.com, wondery.com, npr.org...
Each request will return up to 10 podcasts. You can use the `page` parameter to paginate.

```ruby
require "podcast_api"

client = PodcastApi::Client.new(api_key: ENV["LISTEN_API_KEY"])
response = client.fetch_podcasts_by_domain(**{
  'domain_name' => 'nytimes.com',
  'page' => 1
})
puts response.parsed_response
```

[Full API documentation](https://www.listennotes.com/api/docs/#get-api-v2-podcasts-domains-domain_name)

### create_playlist

Create a playlist.

`POST /playlists`

Create an empty playlist owned by the API admin. Name is required; description defaults to an empty string, visibility defaults to public, and type defaults to episode_list. Set type to podcast_list to make podcasts the default view. The response includes the saved type and its listennotes_url.

Only playlists owned by your admin API account can be modified; contributor membership does not grant write access.

```ruby
require "podcast_api"

client = PodcastApi::Client.new(api_key: ENV["LISTEN_API_KEY"])
response = client.create_playlist(**{
  'name' => 'My favorite podcasts',
  'description' => 'Podcasts and episodes to revisit.',
  'visibility' => 'public',
  'type' => 'episode_list'
})
puts response.parsed_response
```

[Full API documentation](https://www.listennotes.com/api/docs/#post-api-v2-playlists)

### update_playlist

Update playlist metadata.

`PUT /playlists/{id}`

Update any subset of name, description, visibility, and type. Omitted fields remain unchanged; at least one field is required. Switching to private rotates the playlist RSS secret. Type selects the saved default view (episode_list or podcast_list) and the returned listennotes_url; changing it preserves all existing episodes and podcasts.

Only playlists owned by your admin API account can be modified; contributor membership does not grant write access.

```ruby
require "podcast_api"

client = PodcastApi::Client.new(api_key: ENV["LISTEN_API_KEY"])
response = client.update_playlist(**{
  'id' => 'm1pe7z60bsw',
  'name' => 'My favorite podcasts',
  'description' => 'Podcasts and episodes to revisit.',
  'visibility' => 'public',
  'type' => 'podcast_list'
})
puts response.parsed_response
```

[Full API documentation](https://www.listennotes.com/api/docs/#put-api-v2-playlists-id)

### add_playlist_item

Add an episode or podcast to a playlist.

`POST /playlists/{id}/items`

Provide exactly one non-empty episode_id or podcast_id; an empty unused ID field is ignored. Invalid ID formats return 400 and identify the field. A missing episode or podcast returns 404 with an error such as "Episode not found: {episode_id}." or "Podcast not found: {podcast_id}.". Existing active items are reused (200); new or restored items return 201. Omitted notes preserve existing notes, including when restoring a deleted item; supplied notes replace them.

```ruby
require "podcast_api"

client = PodcastApi::Client.new(api_key: ENV["LISTEN_API_KEY"])
response = client.add_playlist_item(**{
  'id' => 'm1pe7z60bsw',
  'episode_id' => 'e53e6992a5b7492f9ea6fcd85d9ad95f',
  'notes' => 'Worth a listen.'
})
puts response.parsed_response
```

[Full API documentation](https://www.listennotes.com/api/docs/#post-api-v2-playlists-id-items)

### delete_playlist_item

Remove an item from a playlist.

`DELETE /playlists/{id}/items/{item_id}`

Delete a playlist item. Repeating deletion of the same item succeeds. This does not delete the episode or podcast from the podcast database.

Only playlists owned by your admin API account can be modified; contributor membership does not grant write access.

```ruby
require "podcast_api"

client = PodcastApi::Client.new(api_key: ENV["LISTEN_API_KEY"])
response = client.delete_playlist_item(**{
  'id' => 'm1pe7z60bsw',
  'item_id' => 23
})
puts response.parsed_response
```

[Full API documentation](https://www.listennotes.com/api/docs/#delete-api-v2-playlists-id-items-item_id)

### update_playlist_item_notes

Update notes for a playlist item.

`PUT /playlists/{id}/items/{item_id}`

Replace item notes, or send an empty string to clear them. The item ID and added_at_ms remain unchanged.

Only playlists owned by your admin API account can be modified; contributor membership does not grant write access.

```ruby
require "podcast_api"

client = PodcastApi::Client.new(api_key: ENV["LISTEN_API_KEY"])
response = client.update_playlist_item_notes(**{
  'id' => 'm1pe7z60bsw',
  'item_id' => 23,
  'notes' => ''
})
puts response.parsed_response
```

[Full API documentation](https://www.listennotes.com/api/docs/#put-api-v2-playlists-id-items-item_id)

<!-- END GENERATED API REFERENCE -->
