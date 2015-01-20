require 'rubygems'
require 'bundler/setup'
#require 'rails/all'
#require 'active_support'


# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)


#load our libs
require File.expand_path('../lib', __FILE__)
Dir['../app/models/*.rb'].each {|file| require file }
Dir['../models/service/*.rb'].each {|file| require file }

module EveryBit
  class Loop
    class << self
      def root
        Pathname.new( File.dirname(__FILE__) + "..")
      end
    end
  end
  
  class Application
    # Settings in config/environments/* take precedence over those specified here.
    def initialize
      @service_config = service_config
      @device_config = device_config
      
      @service = RESTfulClientService.new(
        @device_config['device_id'], 
        @device_config['device_key'], 
        @device_config['site_url'])
      
      #Initialize Device
      @device = Device.new(
        id: @device_config['device_id'],
        key: @device_config['device_key']
      )
      @client = RESTfulClient.new(
        @service_config['client_id'],
        @service_config['secret'],
        { site: @service_config['site'] + @service_config['api_suffix'] }
      )
      EveryBit::ApiBase.client = @client
      
      @device.register
      
      #Initialize profiles in apps directory
      @profiles = {}
      Dir[File.expand_path('../app/profiles', __FILE__)].each { |file|
        
      }
      
      #set up Rack server to listen in to our physical devices
    end
    
private
    def service_config
      service_yaml = File.new(Loop.root.join('config', 'service.yml'))
      YAML.load service_yaml
    end
    
    def device_config
      device_file = Loop.root.join('config', 'device.yml')
      config = nil
      if File.exists? device_file
        device_yaml = File.new(device_file)
        config = YAML.load device_yaml
      else
        config = {
          'device_id' => SecureRandom::uuid,
          'device_key' => SecureRandom::base64,
          'site_url' => "https://api.everybitloop.com/DeviceHive.API/"
        }
      end
      return config
    end
    
    
  end
end
