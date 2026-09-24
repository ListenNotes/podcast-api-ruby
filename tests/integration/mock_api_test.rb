# frozen_string_literal: true

require 'test/unit'
require 'podcast_api'

# Guard the final URI and headers immediately before opening a socket. No env
# API keys, redirects, retries, proxy settings, or production destinations.
class MockOnlyAdapter < HTTParty::ConnectionAdapter
  def connection
    unless uri.scheme == 'https' && uri.host == 'listen-api-test.listennotes.com' &&
           uri.port == 443 && uri.userinfo.nil? && uri.path.start_with?('/api/v2/')
      raise 'Integration tests may only call the public mock API'
    end
    options.fetch(:headers).each do |name, value|
      if name.downcase == 'authorization' || (name.downcase == 'x-listenapi-key' && !value.to_s.empty?)
        raise 'Integration tests must not send credentials'
      end
    end
    super
  end
end

class MockOnlyClient < PodcastApi::Client
  protected

  def send_http_request(method, url, options)
    super(method, url, options.merge(connection_adapter: MockOnlyAdapter,
                                    follow_redirects: false, max_retries: 0,
                                    timeout: 15, open_timeout: 5, http_proxyaddr: nil))
  end
end

class MockApiTest < Test::Unit::TestCase
  CONTRACT = JSON.parse(File.read(File.expand_path('../../lib/api-contract.json', __dir__)))
  BASE = 'https://listen-api-test.listennotes.com/api/v2'

  def setup
    @client = MockOnlyClient.new(api_key: nil)
    assert_equal BASE, @client.base_url
  end

  def assert_response(response, method, path, status = 200)
    assert_kind_of HTTParty::Response, response
    assert_equal status, response.code, response.body.to_s[0, 500]
    assert_equal method, response.request.http_method::METHOD
    assert_equal '/api/v2' + path, response.request.last_uri.path
    assert_match(%r{\Aapplication/json}, response.headers['Content-Type'])
    assert_operator Integer(response.headers['X-ListenAPI-Usage']), :>=, 0
    assert_operator Integer(response.headers['X-ListenAPI-FreeQuota']), :>, 0
    assert_operator Float(response.headers['X-ListenAPI-Latency-Seconds']), :>=, 0
    assert_not_nil response.headers['X-ListenAPI-NextBillingDate']
    assert_kind_of Hash, response.parsed_response
    response.parsed_response
  end

  CONTRACT.fetch('operations').each do |operation|
    define_method("test_mock_#{operation.fetch('func')}") do
      params = operation.fetch('example_params').dup
      path = operation.fetch('path').gsub(/\{([^}]+)\}/) { params.delete(Regexp.last_match(1)).to_s }
      status = %w[createPlaylist addPlaylistItem].include?(operation['operationId']) ? 201 : 200
      response = @client.public_send(operation.fetch('func'), **operation.fetch('example_params'))
      payload = assert_response(response, operation.fetch('method'), path, status)
      unless %w[POST PUT].include?(operation['method'])
        assert_equal params.transform_values(&:to_s), URI.decode_www_form(response.request.last_uri.query.to_s).to_h
      else
        assert_equal params.transform_values(&:to_s), URI.decode_www_form(response.request.options[:body]).to_h
      end
      if %w[createPlaylist updatePlaylist getPlaylistById].include?(operation['operationId'])
        assert_kind_of String, payload.fetch('id')
        assert_include %w[episode_list podcast_list], payload.fetch('type')
        assert_include %w[public unlisted private], payload.fetch('visibility')
        assert_match(%r{\Ahttps://www.listennotes.com/}, payload.fetch('listennotes_url'))
      elsif %w[addPlaylistItem updatePlaylistItemNotes].include?(operation['operationId'])
        assert_kind_of Integer, payload.fetch('id')
        assert_kind_of String, payload.fetch('notes')
        assert_kind_of Hash, payload.fetch('data')
        assert_include %w[episode podcast], payload.fetch('type')
      elsif operation['operationId'] == 'deletePlaylistItem'
        assert_equal true, payload.fetch('deleted')
        assert_kind_of Integer, payload.fetch('id')
      end
    end
  end

  def test_encoded_search
    response = @client.search(q: 'science & café', offset: 0)
    assert_response(response, 'GET', '/search')
    assert_equal({'q' => 'science & café', 'offset' => '0'}, URI.decode_www_form(response.request.last_uri.query).to_h)
  end

  def test_add_podcast_with_notes
    response = @client.add_playlist_item(id: 'm1pe7z60bsw', podcast_id: '4d3fe717742d4963a85562e9f84d8c79', notes: 'hello & café')
    assert_response(response, 'POST', '/playlists/m1pe7z60bsw/items', 201)
    assert_equal({'podcast_id' => '4d3fe717742d4963a85562e9f84d8c79', 'notes' => 'hello & café'},
                 URI.decode_www_form(response.request.options[:body]).to_h)
  end

  def test_empty_description
    response = @client.update_playlist(id: 'm1pe7z60bsw', description: '')
    assert_response(response, 'PUT', '/playlists/m1pe7z60bsw')
    assert_equal 'description=', response.request.options[:body]
  end

  def test_missing_route
    error = assert_raise(PodcastApi::NotFoundError) do
      @client.send(:request_api, 'GET', '/sdk-integration-missing-route', [], {})
    end
    assert_equal 404, error.response.code
  end
end
