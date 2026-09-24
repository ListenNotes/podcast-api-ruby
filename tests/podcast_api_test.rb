# frozen_string_literal: true

require 'test/unit'
require 'webmock/test_unit'
require 'podcast_api'

WebMock.disable_net_connect!

class PodcastApiTest < Test::Unit::TestCase
  CONTRACT = JSON.parse(File.read(File.expand_path('../lib/api-contract.json', __dir__)))
  MOCK = 'https://listen-api-test.listennotes.com/api/v2'
  PROD = 'https://listen-api.listennotes.com/api/v2'

  def setup
    @client = PodcastApi::Client.new
  end

  # Exercise the actual generated methods and HTTParty, not a replacement client.
  CONTRACT.fetch('operations').each do |operation|
    define_method("test_contract_#{operation.fetch('func')}") do
      params = operation.fetch('example_params').dup
      path = operation.fetch('path').gsub(/\{([^}]+)\}/) do
        URI.encode_www_form_component(params.delete(Regexp.last_match(1)).to_s)
      end
      query_names = operation.fetch('parameters').select { |p| p['in'] == 'query' }.map { |p| p['name'] }
      method = operation.fetch('method')
      query, body = params.partition { |name, _| %w[GET DELETE].include?(method) || query_names.include?(name) }.map(&:to_h)
      query = query.transform_values(&:to_s)
      status = %w[createPlaylist addPlaylistItem].include?(operation['operationId']) ? 201 : 200
      request = stub_request(method.downcase.to_sym, MOCK + path).with(query: query)
      if %w[POST PUT].include?(method)
        request = request.with(body: body.transform_values(&:to_s), headers: {'Content-Type' => 'application/x-www-form-urlencoded'})
      else
        request = request.with { |req| req.body.nil? || req.body.empty? }
      end
      request.to_return(status: status, body: '{"ok":true}', headers: {'Content-Type' => 'application/json', 'X-ListenAPI-Usage' => '17'})
      response = @client.public_send(operation.fetch('func'), **operation.fetch('example_params'))
      assert_kind_of HTTParty::Response, response
      assert_equal status, response.code
      assert_equal true, response['ok']
      assert_equal '17', response.headers['X-ListenAPI-Usage']
      assert_requested request, times: 1
    end
  end

  def test_query_encoding_and_false_zero_empty_values
    stub = stub_request(:get, MOCK + '/search').with(query: {
      'q' => 'café & a/b? #+', 'offset' => '0', 'safe_mode' => 'false', 'language' => ''
    }).to_return(body: '{}')
    @client.search(q: 'café & a/b? #+', offset: 0, safe_mode: false, language: '', unused: nil)
    assert_requested stub, times: 1
  end

  def test_nested_path_encoding_and_empty_notes
    params = {id: 'a/b ?#%+é', item_id: 'x/y ?#%+', notes: ''}
    before = params.dup
    stub = stub_request(:put, MOCK + '/playlists/a%2Fb%20%3F%23%25%2B%C3%A9/items/x%2Fy%20%3F%23%25%2B')
           .with(body: 'notes=', query: {}).to_return(body: '{}')
    @client.update_playlist_item_notes(**params)
    assert_equal before, params
    assert_requested stub, times: 1
  end

  def test_put_and_post_separate_query_and_body
    %w[PUT POST].each do |method|
      stub = stub_request(method.downcase.to_sym, MOCK + '/example/id').with(
        query: {'page' => '0'}, body: 'description=&notes=hello+%26+caf%C3%A9&enabled=false'
      ).to_return(body: '{}')
      @client.send(:request_api, method, '/example/{id}', ['page'],
                   {id: 'id', page: 0, description: '', notes: 'hello & café', enabled: false, unused: nil})
      assert_requested stub, times: 1
    end
  end

  def test_omitted_notes_are_not_sent
    stub = stub_request(:post, MOCK + '/playlists/abc/items').with(body: {'episode_id' => 'episode'})
           .to_return(status: 201, body: '{}')
    @client.add_playlist_item(id: 'abc', episode_id: 'episode')
    assert_requested stub, times: 1
  end

  def test_missing_path_parameters_fail_before_network_access
    [{}, {id: nil}, {id: ''}, {id: 'abc'}, {id: 'abc', item_id: nil}, {id: 'abc', item_id: ''}].each do |params|
      error = assert_raise(PodcastApi::InvalidRequestError) { @client.delete_playlist_item(**params) }
      assert_match(/Missing required path parameter:/, error.message)
      assert_nil error.response
    end
    assert_not_requested :any, /listen-api/
  end

  def test_clients_keep_their_own_keys_user_agents_and_timeouts
    key = +'first-key'
    agent = +'custom-agent'
    first = PodcastApi::Client.new(api_key: key, user_agent: agent, timeout: 7)
    second = PodcastApi::Client.new(api_key: 'second-key', timeout: 11)
    key.replace('changed')
    agent.replace('changed')
    [[first, 'first-key', 'custom-agent', 7], [second, 'second-key', "podcast-api-ruby #{PodcastApi::VERSION}", 11],
     [first, 'first-key', 'custom-agent', 7]].each do |client, expected_key, expected_agent, timeout|
      WebMock.reset!
      stub = stub_request(:get, PROD + '/genres').with(headers: {
        'X-ListenAPI-Key' => expected_key, 'User-Agent' => expected_agent
      }).to_return(body: '{}')
      response = client.fetch_podcast_genres
      assert_equal timeout, response.request.options[:timeout]
      assert_equal false, response.request.options[:follow_redirects]
      assert_equal 0, response.request.options[:max_retries]
      assert_requested stub
    end
    assert_equal MOCK, @client.base_url
    assert_equal MOCK, PodcastApi::Client.new(api_key: '').base_url
    adapter = HTTParty::ConnectionAdapter.new(URI(PROD), timeout: 7, max_retries: 0).connection
    assert_equal 0, adapter.max_retries
    assert_equal 7, adapter.open_timeout
    assert_equal 7, adapter.read_timeout
    assert_equal 7, adapter.write_timeout
  end

  def test_post_does_not_change_later_get_headers
    stub_request(:post, MOCK + '/playlists').to_return(status: 201, body: '{}')
    stub_request(:get, MOCK + '/genres').to_return(body: '{}')
    @client.create_playlist(name: 'test')
    response = @client.fetch_podcast_genres
    assert_false response.request.options[:headers].key?('Content-Type')
  end

  def test_invalid_timeouts
    [0, -1, nil, '30', Float::INFINITY, Float::NAN, Complex(1, 2), Rational(1, 2)].each do |timeout|
      assert_raise(ArgumentError) { PodcastApi::Client.new(timeout: timeout) }
    end
  end

  {400 => PodcastApi::InvalidRequestError, 401 => PodcastApi::AuthenticationError,
   403 => PodcastApi::PermissionDeniedError, 404 => PodcastApi::NotFoundError,
   429 => PodcastApi::RateLimitError, 500 => PodcastApi::PodcastApiError}.each do |status, klass|
    define_method("test_error_#{status}_preserves_server_message_and_response") do
      stub = stub_request(:post, MOCK + '/playlists').to_return(
        status: status, body: '{"error":"Specific API error"}', headers: {'X-ListenAPI-Usage' => '5'}
      )
      error = assert_raise(klass) { @client.create_playlist(name: 'test') }
      assert_match(/Specific API error/, error.message)
      assert_equal status, error.response.code
      assert_equal '5', error.response.headers['X-ListenAPI-Usage']
      assert_requested stub, times: 1
    end
  end

  def test_non_json_and_empty_errors_preserve_status
    ['', '<html>unavailable</html>', '[]'].each do |body|
      stub_request(:get, MOCK + '/genres').to_return(status: 502, body: body)
      error = assert_raise(PodcastApi::PodcastApiError) { @client.fetch_podcast_genres }
      assert_match(/HTTP 502/, error.message)
    end
  end

  def test_all_success_statuses_keep_response_envelope
    [200, 201, 202, 204].each do |status|
      stub_request(:post, MOCK + '/playlists').to_return(status: status, body: '')
      response = @client.create_playlist(name: 'test')
      assert_kind_of HTTParty::Response, response
      assert_equal status, response.code
    end
  end

  def test_redirect_is_not_followed
    [301, 302, 303, 307, 308].each do |status|
      stub_request(:post, MOCK + '/playlists').to_return(status: status, headers: {'Location' => PROD + '/playlists'})
      error = assert_raise(PodcastApi::PodcastApiError) { @client.create_playlist(name: 'test') }
      assert_equal status, error.response.code
    end
    assert_not_requested :any, /listen-api\.listennotes\.com/
  end

  def test_connection_failures_are_wrapped_without_retries
    [SocketError, Net::OpenTimeout, Net::ReadTimeout, Net::WriteTimeout, Errno::ECONNREFUSED,
     EOFError, OpenSSL::SSL::SSLError].each do |klass|
      WebMock.reset!
      stub = stub_request(:put, MOCK + '/playlists/abc').to_raise(klass.new('connection failed'))
      assert_raise(PodcastApi::APIConnectionError) { @client.update_playlist(id: 'abc', description: '') }
      assert_requested stub, times: 1
    end
  end

  def test_readme_examples_cover_contract_and_are_valid_ruby
    readme = File.read(File.expand_path('../README.md', __dir__))
    CONTRACT.fetch('operations').each do |operation|
      func = operation.fetch('func')
      assert_equal 1, readme.scan(/^### #{func}$/).size
      assert_include readme, "client.#{func}("
    end
    readme.scan(/```ruby\n(.*?)\n```/m).each { |example| RubyVM::InstructionSequence.compile(example.first) }
    assert_equal CONTRACT.fetch('version'), PodcastApi::VERSION
    assert_equal CONTRACT.fetch('operations').map { |op| op.fetch('func').to_sym }.sort,
                 PodcastApi::ApiMethods.instance_methods(false).sort
    add = CONTRACT.fetch('operations').find { |op| op['operationId'] == 'addPlaylistItem' }.fetch('example_params')
    assert_equal 1, %w[episode_id podcast_id].count { |key| add.key?(key) }
  end
end
