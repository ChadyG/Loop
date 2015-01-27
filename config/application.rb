require 'rubygems'
require 'bundler/setup'
require 'yaml'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default)

module EveryBit
  class Loop
    class << self
      def root
        Pathname.new( File.expand_path("../..", __FILE__) )
      end
    end
  end

  class Application
    # Settings in config/environments/* take precedence over those specified here.
    def initialize
      @service_config = service_config
      @device_config = device_config

      #Initialize Device
      @device = Device.new(
        id: @device_config['device_id'],
        key: @device_config['device_key']
      )
      @device.name = "RackClient"
      @device.device_type = {name: "RackType", version: "1.0"}
      @client = RESTfulClient.new(
        @service_config['client_id'],
        @service_config['secret'],
        {
          site: @service_config['site'],
          api_suffix: @service_config['api_suffix']
        }
      )
      @client.device = @device
      EveryBit::ApiBase.client = @client

      @device.register

      #Initialize profiles in apps directory
      @profiles = {}
      Dir[Loop.root.join('app','profiles','*.rb')].each { |file|
        #puts "each #{file}"
        require Loop.root.join(file)
        file_name = File.basename(file, ".rb")
        route_name = file_name.gsub(/^[a-z0-9]|_[a-z0-9]/){ |a| a.downcase }.gsub(/_/,"")
        class_name = route_name.capitalize
        #puts "adding /#{route_name} => #{class_name}"
        @profiles["/"+ route_name] = Module.const_get(class_name).new
      }

      #set up Rack server to listen in to our physical devices
      @app = Rack::URLMap.new(@profiles)
    end

    def call(env)
      @app.call(env)
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


#load our libs
Dir['lib/*.rb'].each {|file| require EveryBit::Loop.root.join(file) }
#Dir['app/models/*.rb'].each {|file| require EveryBit::Loop.root.join(file) }
require EveryBit::Loop.root.join('app/models/base.rb')
require EveryBit::Loop.root.join('app/models/profile.rb')
require EveryBit::Loop.root.join('app/models/device.rb')
Dir['app/service/*.rb'].each {|file| require EveryBit::Loop.root.join(file) }
