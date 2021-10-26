require "podcast_api"

api_key = ENV["LISTEN_API_KEY"]
client = PodcastApi::Client.new(api_key: api_key)

begin
    response = client.search(q: 'startup')
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

# response = client.spellcheck(q: 'evergrand stok')
# puts JSON.parse(response.body)

# response = client.fetch_related_searches(q: 'evergrande')
# puts JSON.parse(response.body)

# response = client.fetch_trending_searches()
# puts JSON.parse(response.body)

# response = client.typeahead(q: 'startup', show_podcasts: 1)
# puts JSON.parse(response.body)

# response = client.fetch_best_podcasts()
# puts JSON.parse(response.body)

# response = client.fetch_podcast_by_id(id: '4d3fe717742d4963a85562e9f84d8c79')
# puts JSON.parse(response.body)

# response = client.fetch_episode_by_id(id: '6b6d65930c5a4f71b254465871fed370')
# puts JSON.parse(response.body)

# response = client.batch_fetch_podcasts(ids: '3302bc71139541baa46ecb27dbf6071a,68faf62be97149c280ebcc25178aa731,37589a3e121e40debe4cef3d9638932a,9cf19c590ff0484d97b18b329fed0c6a')
# puts JSON.parse(response.body)

# response = client.batch_fetch_episodes(ids: 'c577d55b2b2b483c969fae3ceb58e362,0f34a9099579490993eec9e8c8cebb82')
# puts JSON.parse(response.body)

# response = client.fetch_curated_podcasts_list_by_id(id: 'SDFKduyJ47r')
# puts JSON.parse(response.body)

# response = client.fetch_podcast_genres()
# puts JSON.parse(response.body)

# response = client.fetch_podcast_regions()
# puts JSON.parse(response.body)

# response = client.fetch_podcast_languages()
# puts JSON.parse(response.body)

# response = client.just_listen()
# puts JSON.parse(response.body)

# response = client.fetch_recommendations_for_podcast(id: '25212ac3c53240a880dd5032e547047b')
# puts JSON.parse(response.body)

# response = client.fetch_recommendations_for_episode(id: '914a9deafa5340eeaa2859c77f275799')
# puts JSON.parse(response.body)

# response = client.fetch_playlist_by_id(id: 'm1pe7z60bsw')
# puts JSON.parse(response.body)

# response = client.fetch_my_playlists()
# puts JSON.parse(response.body)

# response = client.submit_podcast(rss: 'https://feeds.megaphone.fm/committed')
# puts JSON.parse(response.body)

# response = client.delete_podcast(id: '4d3fe717742d4963a85562e9f84d8c79')
# puts JSON.parse(response.body)
