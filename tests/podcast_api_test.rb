require 'test/unit'
require 'mocha/test_unit'

require './lib/podcast_api.rb'

class PodcastApiTest < Test::Unit::TestCase
  def test_search_with_mock
    client = PodcastApi::Client.new
    response = client.search(q: 'test')
    assert_equal response['count'], 10
  end

  def test_search_auth_error
    api_key = 'wrong key'
    client = PodcastApi::Client.new api_key:api_key
    assert_raise(PodcastApi::AuthenticationError) { 
        client.search(q: 'test')
    }
  end  
end
