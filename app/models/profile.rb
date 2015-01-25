module EveryBit
  class Profile < ApiBase
    property :id, required: true
    property :name, required: true, message: 'must be set.'
    property :code
    property :type
    property :description
    property :data
    property :parameters
    property :commands
  end
end