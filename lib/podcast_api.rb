# frozen_string_literal: true

require 'httparty'
require 'json'
require 'uri'
require_relative 'version'
require_relative 'errors'
require_relative 'api_methods'

module PodcastApi
  class Client
    include HTTParty
    include ApiMethods

    BASE_URL_PROD = 'https://listen-api.listennotes.com/api/v2'
    BASE_URL_TEST = 'https://listen-api-test.listennotes.com/api/v2'
    attr_reader :base_url

    def initialize(api_key: nil, user_agent: nil, timeout: 30)
      unless (timeout.is_a?(Integer) || timeout.is_a?(Float)) && timeout.finite? && timeout.positive?
        raise ArgumentError, 'timeout must be a positive, finite number of seconds'
      end
      @base_url = (api_key.nil? || api_key.empty?) ? BASE_URL_TEST : BASE_URL_PROD
      @headers = {
        'X-ListenAPI-Key' => api_key.to_s.dup.freeze,
        'User-Agent' => (user_agent || "podcast-api-ruby #{VERSION}").dup.freeze
      }.freeze
      @timeout = timeout
    end

    protected

    def request_api(method, path, query_names, kwargs)
      params = kwargs.transform_keys(&:to_s)
      path = path.gsub(/\{([^}]+)\}/) do
        name = Regexp.last_match(1)
        value = params.delete(name)
        if value.nil? || value.to_s.empty?
          raise InvalidRequestError, "Missing required path parameter: #{name}"
        end
        URI.encode_www_form_component(value.to_s).gsub('+', '%20')
      end
      params.reject! { |_, value| value.nil? }
      query, body = params.partition { |name, _| %w[GET DELETE].include?(method) || query_names.include?(name) }.map(&:to_h)
      options = {
        headers: @headers.dup, query: query, timeout: @timeout,
        # Net::HTTP otherwise retries some write methods on broken connections.
        follow_redirects: false, max_retries: 0
      }
      if %w[POST PUT].include?(method)
        options[:headers]['Content-Type'] = 'application/x-www-form-urlencoded'
        options[:body] = URI.encode_www_form(body)
      end
      send_http_request(method.downcase, "#{@base_url}#{path}", options)
    end

    def send_http_request(http_method, *args)
      response = HTTParty.public_send(http_method, *args)
      get_response(response: response)
    rescue SocketError, SystemCallError, Timeout::Error, IOError, EOFError, OpenSSL::SSL::SSLError => error
      raise APIConnectionError, "Failed to connect to Listen API servers (#{error.class})"
    end

    def get_response(response:)
      return response if (200..299).cover?(response.code)

      error_class = {
        400 => InvalidRequestError,
        401 => AuthenticationError,
        403 => PermissionDeniedError,
        404 => NotFoundError,
        429 => RateLimitError
      }.fetch(response.code, PodcastApiError)
      message = "Listen API returned HTTP #{response.code}"
      begin
        payload = JSON.parse(response.body.to_s)
        detail = payload['error'] || payload['message'] if payload.is_a?(Hash)
        message += ": #{detail}" if detail.is_a?(String) && !detail.empty?
      rescue JSON::ParserError
        # Preserve a useful status message for HTML, empty, or malformed bodies.
      end
      raise error_class.new(message, response: response)
    end
  end
end
