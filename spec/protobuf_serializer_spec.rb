require 'spec_helper'

module Protobuf
  module Model
    class Permission
      include ActiveModel::Model

      attr_accessor :admin
    end

    class Member
      include ActiveModel::Model

      attr_accessor :name
    end

    class Members
      include ActiveModel::Model

      attr_accessor :members, :permission, :flag
    end

    class PermissionSerializer < ProtobufSerializer::Base
      attributes :admin
    end

    class MemberSerializer < ProtobufSerializer::Base
      attributes :name

      def name
        object.name.upcase
      end
    end

    class MembersSerializer < ProtobufSerializer::Base
      has_many :members, serializer: Protobuf::Model::MemberSerializer
      has_one :permission, serializer: Protobuf::Model::PermissionSerializer

      attributes :flag

      def flag
        object.flag ? 'Write' : 'Read'
      end
    end
  end
end

class Permission
  include ActiveModel::Model
  include ActiveModel::Serialization

  attr_accessor :admin
end

class Member
  include ActiveModel::Model
  include ActiveModel::Serialization

  attr_accessor :name
end

describe ProtobufSerializer do
  let(:permission) { { admin: true } }
  let(:members) do
    {
      members: [Member.new(name: 'Nguyen'), Member.new(name: 'Tien')],
      permission: Permission.new(admin: true),
      flag: false
    }
  end
  let(:empty_members) do
    {
      members: [],
      permission: nil,
      flag: nil
    }
  end

  before do
    ActiveModelSerializers::Adapter.register(:protobuf, ProtobufSerializer::ProtobufAdapter)
  end

  it 'serializes into Protobuf object' do
    result = Protobuf::Model::PermissionSerializer.serialize(permission)

    expect(result).to be_a_kind_of(Protobuf::Model::Permission)
    expect(result.admin).to eq(true)
  end

  it 'serializes into Protobuf object with a collection inside' do
    result = Protobuf::Model::MembersSerializer.serialize(members)

    expect(result.members.first).to be_a_kind_of(Protobuf::Model::Member)
    expect(result.members.map(&:name)).to match_array(%w(NGUYEN TIEN))
    expect(result.permission).to be_a_kind_of(Protobuf::Model::Permission)
    expect(result.flag).to eq('Read')
  end

  it 'serializes empty object' do
    result = Protobuf::Model::MembersSerializer.serialize(empty_members)

    expect(result.members).to eq([])
    expect(result.permission).to eq(nil)
    expect(result.flag).to eq('Read')
  end
end
