require 'test/unit'
require 'mocha/test_unit'

require './lib/podcast_api.rb'

class PodcastApiTest < Test::Unit::TestCase
  def test_search_with_mock
    term = 'test123'
    client = PodcastApi::Client.new
    response = client.search(q: term)
    assert_equal response.request.options[:query][:q], term
    assert_equal response.request.http_method, Net::HTTP::Get
    assert_equal response.request.path.path, '/api/v2/search'
    assert response['count'] > 0
  end

  def test_search_auth_error
    api_key = 'wrong key'
    client = PodcastApi::Client.new api_key:api_key
    assert_raise(PodcastApi::AuthenticationError) { 
        client.search(q: 'test')
    }
  end

  def test_typeahead_with_mock
    term = 'test123'
    client = PodcastApi::Client.new
    response = client.typeahead(q: term, show_podcasts: 1)
    assert_equal response.request.options[:query][:q], term
    assert_equal response.request.options[:query][:show_podcasts], 1
    assert_equal response.request.http_method, Net::HTTP::Get
    assert_equal response.request.path.path, '/api/v2/typeahead'
    assert response['terms'].length > 0
  end  

  def test_spellcheck_with_mock
    term = 'test123'
    client = PodcastApi::Client.new
    response = client.spellcheck(q: term)
    assert_equal response.request.options[:query][:q], term
    assert_equal response.request.http_method, Net::HTTP::Get
    assert_equal response.request.path.path, '/api/v2/spellcheck'
    assert response['tokens'].length > 0
  end   
  
  def test_related_searches_with_mock
    term = 'test123'
    client = PodcastApi::Client.new
    response = client.fetch_related_searches(q: term)
    assert_equal response.request.options[:query][:q], term
    assert_equal response.request.http_method, Net::HTTP::Get
    assert_equal response.request.path.path, '/api/v2/related_searches'
    assert response['terms'].length > 0
  end     

  def test_trending_searches_with_mock
    client = PodcastApi::Client.new
    response = client.fetch_trending_searches()
    assert_equal response.request.http_method, Net::HTTP::Get
    assert_equal response.request.path.path, '/api/v2/trending_searches'
    assert response['terms'].length > 0
  end       

  def test_fetch_best_podcasts_with_mock
    genre_id = 123
    client = PodcastApi::Client.new
    response = client.fetch_best_podcasts(genre_id: genre_id)
    assert_equal response.request.options[:query][:genre_id], genre_id
    assert_equal response.request.http_method, Net::HTTP::Get
    assert_equal response.request.path.path, '/api/v2/best_podcasts'
    assert response['total'] > 0
  end   
  
  def test_fetch_podcast_by_id_with_mock
    id = 'ddddd'
    client = PodcastApi::Client.new
    response = client.fetch_podcast_by_id(id: id)
    assert_equal response.request.http_method, Net::HTTP::Get
    assert_equal response.request.path.path, "/api/v2/podcasts/#{id}"
    assert response['episodes'].length > 0
  end  

  def test_fetch_episode_by_id_with_mock
    id = 'aaaaaa'
    client = PodcastApi::Client.new
    response = client.fetch_episode_by_id(id: id)
    assert_equal response.request.http_method, Net::HTTP::Get
    assert_equal response.request.path.path, "/api/v2/episodes/#{id}"
    assert response['podcast']['rss'].length > 0
  end  

  def test_batch_fetch_podcasts_with_mock
    ids = '996,777,888,1000'
    client = PodcastApi::Client.new
    response = client.batch_fetch_podcasts(ids: ids)
    assert_equal response.request.http_method, Net::HTTP::Post
    assert_equal response.request.path.path, "/api/v2/podcasts"
    assert_equal response.request.options[:body][:ids], ids
  end  

  def test_batch_fetch_episodes_with_mock
    ids = '996,777,888,1000'
    client = PodcastApi::Client.new
    response = client.batch_fetch_episodes(ids: ids)
    assert_equal response.request.http_method, Net::HTTP::Post
    assert_equal response.request.path.path, "/api/v2/episodes"
    assert_equal response.request.options[:body][:ids], ids
  end 
  
  def test_fetch_curated_podcasts_list_by_id_with_mock
    id = 'abcde'
    client = PodcastApi::Client.new
    response = client.fetch_curated_podcasts_list_by_id(id: id)
    assert_equal response.request.http_method, Net::HTTP::Get
    assert_equal response.request.path.path, "/api/v2/curated_podcasts/#{id}"
    assert response['podcasts'].length > 0
  end  
  
  def test_fetch_curated_podcasts_lists_with_mock
    page = 7
    client = PodcastApi::Client.new
    response = client.fetch_curated_podcasts_lists(page: page)
    assert_equal response.request.http_method, Net::HTTP::Get
    assert_equal response.request.options[:query][:page], page    
    assert_equal response.request.path.path, "/api/v2/curated_podcasts"
    assert response['total'] > 0
  end  

  def test_fetch_podcast_genres_with_mock
    top_level_only = 1
    client = PodcastApi::Client.new
    response = client.fetch_podcast_genres(top_level_only: top_level_only)
    assert_equal response.request.http_method, Net::HTTP::Get
    assert_equal response.request.options[:query][:top_level_only], top_level_only    
    assert_equal response.request.path.path, "/api/v2/genres"
    assert response['genres'].length > 0
  end  

  def test_fetch_podcast_regions_with_mock
    client = PodcastApi::Client.new
    response = client.fetch_podcast_regions()
    assert_equal response.request.http_method, Net::HTTP::Get
    assert_equal response.request.path.path, "/api/v2/regions"
    assert response['regions'].length > 0
  end  

  def test_fetch_podcast_languages_with_mock
    client = PodcastApi::Client.new
    response = client.fetch_podcast_languages()
    assert_equal response.request.http_method, Net::HTTP::Get
    assert_equal response.request.path.path, "/api/v2/languages"
    assert response['languages'].length > 0
  end  

  def test_just_listen_with_mock
    client = PodcastApi::Client.new
    response = client.just_listen()
    assert_equal response.request.http_method, Net::HTTP::Get
    assert_equal response.request.path.path, "/api/v2/just_listen"
    assert response['audio_length_sec'] > 0
  end 

  def test_fetch_playlist_by_id_with_mock
    id = 'aasdfsd'
    client = PodcastApi::Client.new
    response = client.fetch_playlist_by_id(id: id)
    assert_equal response.request.http_method, Net::HTTP::Get
    assert_equal response.request.path.path, "/api/v2/playlists/#{id}"
    assert response['items'].length > 0
  end  

  def test_submit_podcast_with_mock
    rss = 'http://myrss.com/rss'
    client = PodcastApi::Client.new
    response = client.submit_podcast(rss: rss)
    assert_equal response.request.http_method, Net::HTTP::Post
    assert_equal response.request.path.path, "/api/v2/podcasts/submit"
    assert response['status'].length > 0
  end  
  
  def test_delete_podcast_with_mock
    id = 'adfass'
    client = PodcastApi::Client.new
    response = client.delete_podcast(id: id)
    assert_equal response.request.http_method, Net::HTTP::Delete
    assert_equal response.request.path.path, "/api/v2/podcasts/#{id}"    
    assert response['status'].length > 0
  end  

  def test_fetch_my_playlists_with_mock
    client = PodcastApi::Client.new
    response = client.fetch_my_playlists()
    assert_equal response.request.http_method, Net::HTTP::Get
    assert_equal response.request.path.path, "/api/v2/playlists"
    assert response['total'] > 0
  end   
  
  def test_fetch_recommendations_for_podcast_with_mock
    id = 'abcde'
    client = PodcastApi::Client.new
    response = client.fetch_recommendations_for_podcast(id: id)
    assert_equal response.request.http_method, Net::HTTP::Get
    assert_equal response.request.path.path, "/api/v2/podcasts/#{id}/recommendations"
    assert response['recommendations'].length > 0
  end  
  
  def test_fetch_recommendations_for_episode_with_mock
    id = 'abcdedd'
    client = PodcastApi::Client.new
    response = client.fetch_recommendations_for_episode(id: id)
    assert_equal response.request.http_method, Net::HTTP::Get
    assert_equal response.request.path.path, "/api/v2/episodes/#{id}/recommendations"
    assert response['recommendations'].length > 0
  end  
end
