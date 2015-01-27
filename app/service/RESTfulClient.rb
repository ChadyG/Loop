require 'active_support'
require 'faraday'
require 'oauth2'

module EveryBit
  class RESTfulClient
    class << self
    end
    
    # Device
    # 
    attr_accessor :device
    
    def initialize(client_id, client_secret, options = {}, &block)
      opts = options.dup
      @id = client_id
      @secret = client_secret
      @site = opts.delete(:site)
      @site_suffix = opts.delete(:api_suffix)
      @options = {:site             => @site + @site_suffix,
                  :token_url        => @site + @site_suffix + '/token',
                  :connection_opts  => {},
                  :connection_build => block,
                  :max_redirects    => 5,
                  :raise_errors     => true}.merge(opts)
      @oauth_client = nil
      @token = nil
      
      @connection = Faraday.new(:url => @site, :ssl => @options[:ssl]) do |faraday|
        faraday.request  :url_encoded             # form-encode POST params
        faraday.response :logger                  # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end
    end
    
    #request.Headers["Auth-DeviceID"] = deviceId.ToString();
    #request.Headers["Auth-DeviceKey"] = deviceKey;
    def get(path)
      return nil unless retrieve_access_token
      @connection.get do |req|
        req.url @site_suffix + path
        req.headers['Content-Type'] = 'application/json'
        req.headers['Authorization'] = "Bearer " + @token.token
        req.headers['Auth-DeviceID'] = @device.id
        req.headers['Auth-DeviceKey'] = @device.key
      end
    end
    
    def post(path, data)
      return nil unless retrieve_access_token
      @connection.post do |req|
        req.url @site_suffix + path
        req.headers['Content-Type'] = 'application/json'
        req.headers['Authorization'] = "Bearer " + @token.token
        req.headers['Auth-DeviceID'] = @device.id
        req.headers['Auth-DeviceKey'] = @device.key
        req.body = data
      end
    end
    
    def put(path, data)
      return nil unless retrieve_access_token
      @connection.put do |req|
        req.url @site_suffix + path
        req.headers['Content-Type'] = 'application/json'
        req.headers['Authorization'] = "Bearer " + @token.token
        req.headers['Auth-DeviceID'] = @device.id
        req.headers['Auth-DeviceKey'] = @device.key
        req.body = data
      end
    end
    
    def delete(path)
      return nil unless retrieve_access_token
      @connection.delete do |req|
        req.url @site_suffix + path
        req.headers['Content-Type'] = 'application/json'
        req.headers['Authorization'] = "Bearer " + @token.token
        req.headers['Auth-DeviceID'] = @device.id
        req.headers['Auth-DeviceKey'] = @device.key
      end
    end
    
private
    def oauth_client
      return @oauth_client unless @oauth_client.nil?
      site = @site + @site_suffix
      
      @oauth_client = OAuth2::Client.new(@id, @secret, @options)
    end
    
    def retrieve_access_token(refresh = false)
      if refresh or @token.nil? or @token.token.nil?
        @token = oauth_client.client_credentials.get_token
      end
      return !@token.nil?# and !@token.token.nil?
    end
    
    def retrieve_access_token_if_expired(response)
      #todo
    end
  end
end
