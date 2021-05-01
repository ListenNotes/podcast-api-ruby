# frozen_string_literal: true

module PodcastApi
    # PodcastApiError is the base error from which all other more specific PodcastApi
    # errors derive.
    class PodcastApiError < StandardError
    end
  
    class AuthenticationError < PodcastApiError
    end
  
    class APIConnectionError < PodcastApiError
    end
  
    class InvalidRequestError < PodcastApiError
    end
  
    class RateLimitError < PodcastApiError
    end
  
    class NotFoundError < PodcastApiError
    end           
end
