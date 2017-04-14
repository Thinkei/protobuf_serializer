require 'protobuf_serializer/version'
require 'active_model_serializers'

module ProtobufSerializer
  class Base < ActiveModel::Serializer
    # consider to add adatper_options to this method
    def self.serialize(object)
      object = OpenStruct.new(object) if object.is_a?(Hash)
      serializer = new(object)
      ProtobufSerializer::ProtobufAdapter.new(serializer).serializable_hash
    end
  end

  class ProtobufAdapter < ActiveModelSerializers::Adapter::Base
    def serializable_hash(*)
      process_serializer(serializer)
    end

    private

    def process_serializer(serializer)
      return unless serializer && serializer.object
      serialized_hash = serializer.attributes

      serializer.associations.each do |association|
        serialized_hash[association.key] =
          process_association(association.serializer)
      end

      protobuf_class(serializer).new(serialized_hash)
    end

    def process_association(serializer)
      if serializer.respond_to? :each
        return serializer.map(&method(:process_serializer))
      end

      process_serializer(serializer)
    end

    def protobuf_class(serializer)
      Module.const_get(serializer.class.name.gsub('Serializer', ''))
    end
  end

  class OpenStruct 
    include ActiveModel::Model
    include ActiveModel::Serialization

    def initialize(options)
      options.keys.each do |key|
        self.class.send :attr_accessor, key
      end

      super
    end
  end
end
