module EveryBit
  class Device < ApiBase
    property :id, required: true
    property :key, required: true, message: 'must be set.'
    property :name
    property :status
    property :data
    property :device_type
    #profile will just be parameters and command callbacks
    #has_many :profile
    
    def register
      puts "register"
      ApiBase.client.put("/device/#{self.id}", self.to_json)
    end
  end
end
