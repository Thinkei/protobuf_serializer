# ProtobufSerializer
ProtoBuf Serializer is a gem that helps to serialize to Protobuf objects.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'protobuf_serializer'
```

And then execute:

$ bundle

Or install it yourself as:

$ gem install protobuf_serializer

## Usage

### Declaration
With pre-defined models, you need to define a new serializer class, which shows the attributes that need to be serialized.

#### Example Model
```ruby
    class Permission
      include ActiveModel::Model

      attr_accessor :admin
    end
```

#### Serializer Class
```ruby
class PermissionSerializer < ProtobufSerializer::Base
attributes :admin
end
```

### Call
```ruby
result = Protobuf::Model::PermissionSerializer.serialize(permission)
```
## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/protobuf_serializer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

