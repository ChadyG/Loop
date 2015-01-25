require 'faraday'
require 'oauth2'

module EveryBit
  class RESTfulClient
    class << self
    end
    
    def initialize(client_id, client_secret, options = {}, &block)
      opts = options.dup
      @id = client_id
      @secret = client_secret
      @site = opts.delete(:site)
      ssl = opts.delete(:ssl)
      @options = {:token_url        => '/token',
                  :connection_opts  => {},
                  :connection_build => block,
                  :max_redirects    => 5,
                  :raise_errors     => true}.merge(opts)
      @options[:connection_opts][:ssl] = ssl if ssl
      @oauth_client = nil
      @token = nil
    end
    
    def get
      return nil unless retrieve_access_token
      
    end
    
    def post
      return nil unless retrieve_access_token
    
    end
    
    def put
      return nil unless retrieve_access_token
    
    end
    
    def delete
      return nil unless retrieve_access_token
    
    end
    
private
    def oauth_client
      return @oauth_client unless @oauth_client.nil?
      @oauth_client = OAuth2::Client.new(@id, @secret, site: @site, token_url: @site + options[:token_url])
    end
    
    def retrieve_access_token(refresh = false)
      if refresh or @token.try(:access_token).nil?
        @token = oauth_client.client_credentials.get_token
      end
      return !@token.try(:token).nil?
    end
    
    def retrieve_access_token_if_expired(response)
      #todo
    end
  end
end
