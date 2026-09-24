# frozen_string_literal: true

module PodcastApi
  class PodcastApiError < StandardError
    attr_reader :response

    def initialize(message = nil, response: nil)
      @response = response
      super(message)
    end
  end

  class AuthenticationError < PodcastApiError; end
  class APIConnectionError < PodcastApiError; end
  class InvalidRequestError < PodcastApiError; end
  class PermissionDeniedError < PodcastApiError; end
  class RateLimitError < PodcastApiError; end
  class NotFoundError < PodcastApiError; end
end
