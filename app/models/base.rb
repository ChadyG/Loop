module EveryBit
  class ApiBase < Hashie::Dash
    include Hashie::Extensions::Coercion
    
    class << self
      # Wrap Hashie coercion to look like ActiveRecord::Relations
      #
      def has_one(model)
        property model
        coerce_value model, Kernel.const_get(model.to_s.capitalize)
      end
      
      def has_many(model)
        property model
        coerce_value model, ApiBase[Kernel.const_get(model.to_s.capitalize)]
      end
      
      # Connection
      # 
      attr_accessor :client
    end
  end
end
