require "protobuf_serializer/version"
require 'active_model_serializers'

module ProtobufSerializer
  class ProtobufAdapter < ActiveModelSerializers::Adapter::Base
    def serializable_hash(options = nil)
      process_serializer(serializer)
    end

    private

    def process_serializer(serializer)
      return unless serializer && serializer.object
      serialized_hash = serializer.attributes

      serializer.associations.each do |association|
        serialized_hash[association.key] = process_association(association.serializer)
      end

      protobuf_class(serializer).new(serialized_hash)
    end

    def process_association(serializer)
      if serializer.respond_to? :each 
        return serializer.map do |ser|
          process_serializer(ser) 
        end
      end

      process_serializer(serializer)
    end

    def protobuf_class(serializer)
      Module.const_get(serializer.class.name.gsub('Serializer', ''))
    end
  end
end
