# frozen_string_literal: true

require 'httparty'

# Version
require 'version'
require 'errors'

module PodcastApi

    class Client
        include HTTParty

        @@BASE_URL_PROD = 'https://listen-api.listennotes.com/api/v2'
        @@BASE_URL_TEST = 'https://listen-api-test.listennotes.com/api/v2'

        attr_reader :base_url

        def initialize(api_key: nil, user_agent: nil)
            @api_key = api_key
            @base_url = api_key ? @@BASE_URL_PROD : @@BASE_URL_TEST
            @headers = {
                'X-ListenAPI-Key' => @api_key ? @api_key : '',
                'User-Agent' => user_agent ? user_agent : "podcasts-api-ruby #{VERSION}"
            }
        end    

        protected
        def get_response(response:)
            if response.code == 200
                return response
            elsif response.code == 400
                raise InvalidRequestError.new 'something wrong on your end (client side errors), e.g., missing required parameters'
            elsif response.code == 401
                raise AuthenticationError.new 'wrong api key or your account is suspended'
            elsif response.code == 404
                raise NotFoundError.new 'endpoint not exist, or podcast / episode not exist'
            elsif response.code == 429
                raise RateLimitError.new 'you are using FREE plan and you exceed the quota limit'
            else
                raise PodcastApiError.new 'something wrong on our end (unexpected server errors)'
            end
        end

        def send_http_request(http_method, *args)
            begin
                response = HTTParty.public_send(http_method, *args)
            rescue SocketError
                raise APIConnectionError.new 'Failed to connect to Listen API servers'
            else
                return get_response(response: response)
            end
        end

        public
        def search(**kwargs)
            return send_http_request('get', "#{@base_url}/search", {query: kwargs, headers: @headers})
        end

        def typeahead(**kwargs)
            return send_http_request('get', "#{@base_url}/typeahead", {query: kwargs, headers: @headers})
        end
        
        def spellcheck(**kwargs)
            return send_http_request('get', "#{@base_url}/spellcheck", {query: kwargs, headers: @headers})
        end
        
        def fetch_related_searches(**kwargs)
            return send_http_request('get', "#{@base_url}/related_searches", {query: kwargs, headers: @headers})
        end
        
        def fetch_trending_searches(**kwargs)
            return send_http_request('get', "#{@base_url}/trending_searches", {query: kwargs, headers: @headers})
        end

        def fetch_best_podcasts(**kwargs)
            return send_http_request('get', "#{@base_url}/best_podcasts", {query: kwargs, headers: @headers})
        end
        
        def fetch_podcast_by_id(**kwargs)
            id = kwargs.delete(:id)
            return send_http_request('get', "#{@base_url}/podcasts/#{id}", {query: kwargs, headers: @headers})
        end        

        def fetch_episode_by_id(**kwargs)
            id = kwargs.delete(:id)
            return send_http_request('get', "#{@base_url}/episodes/#{id}", {query: kwargs, headers: @headers})
        end        

        def batch_fetch_podcasts(**kwargs)
            @headers['Content-Type'] = 'application/x-www-form-urlencoded'            
            return send_http_request('post', "#{@base_url}/podcasts", {body: kwargs, headers: @headers})
        end         

        def batch_fetch_episodes(**kwargs)
            @headers['Content-Type'] = 'application/x-www-form-urlencoded'            
            return send_http_request('post', "#{@base_url}/episodes", {body: kwargs, headers: @headers})
        end              

        def fetch_curated_podcasts_list_by_id(**kwargs)
            id = kwargs.delete(:id)            
            return send_http_request('get', "#{@base_url}/curated_podcasts/#{id}", {query: kwargs, headers: @headers})
        end      
        
        def fetch_curated_podcasts_lists(**kwargs)
            return send_http_request('get', "#{@base_url}/curated_podcasts", {query: kwargs, headers: @headers})
        end              
        
        def fetch_podcast_genres(**kwargs)
            return send_http_request('get', "#{@base_url}/genres", {query: kwargs, headers: @headers})
        end         
        
        def fetch_podcast_regions(**kwargs)
            return send_http_request('get', "#{@base_url}/regions", {query: kwargs, headers: @headers})
        end                   

        def fetch_podcast_languages(**kwargs)
            return send_http_request('get', "#{@base_url}/languages", {query: kwargs, headers: @headers})
        end            

        def just_listen(**kwargs)
            return send_http_request('get', "#{@base_url}/just_listen", {query: kwargs, headers: @headers})
        end           

        def fetch_recommendations_for_podcast(**kwargs)
            id = kwargs.delete(:id)            
            return send_http_request('get', "#{@base_url}/podcasts/#{id}/recommendations", {query: kwargs, headers: @headers})
        end           
        
        def fetch_recommendations_for_episode(**kwargs)
            id = kwargs.delete(:id)            
            return send_http_request('get', "#{@base_url}/episodes/#{id}/recommendations", {query: kwargs, headers: @headers})
        end     
        
        def fetch_playlist_by_id(**kwargs)
            id = kwargs.delete(:id)            
            return send_http_request('get', "#{@base_url}/playlists/#{id}", {query: kwargs, headers: @headers})
        end     
        
        def fetch_my_playlists(**kwargs)
            return send_http_request('get', "#{@base_url}/playlists", {query: kwargs, headers: @headers})
        end  
        
        def submit_podcast(**kwargs)
            @headers['Content-Type'] = 'application/x-www-form-urlencoded'            
            return send_http_request('post', "#{@base_url}/podcasts/submit", {body: kwargs, headers: @headers})
        end       
        
        def delete_podcast(**kwargs)
            id = kwargs.delete(:id)            
            return send_http_request('delete', "#{@base_url}/podcasts/#{id}", {query: kwargs, headers: @headers})
        end        
    end

end
