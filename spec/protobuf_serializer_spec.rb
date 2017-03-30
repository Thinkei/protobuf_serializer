require "spec_helper"

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
  end
end

class Protobuf::Model::PermissionSerializer < ActiveModel::Serializer
  attributes :admin
end

class Protobuf::Model::MemberSerializer < ActiveModel::Serializer
  attributes :name

  def name
    object.name.upcase
  end
end

class Protobuf::Model::MembersSerializer < ActiveModel::Serializer
  has_many :members, serializer: Protobuf::Model::MemberSerializer
  has_one :permission, serializer: Protobuf::Model::PermissionSerializer

  attributes :flag

  def flag
    object.flag ? "Write" : "Read"
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

class Members
  include ActiveModel::Model
  include ActiveModel::Serialization

  attr_accessor :members, :permission, :flag
end

describe ProtobufSerializer do
  let(:permission) { Permission.new(admin: true) }
  let(:members) do
    Members.new(
      members: [Member.new(name: "Nguyen"), Member.new(name: "Tien")], 
      permission: Permission.new(admin: true),
      flag: false)
  end
  let(:empty_members) do
    Members.new(
      members: [],
      permission: nil,
      flag: nil
    )
  end

  before do
    ActiveModelSerializers::Adapter.register(:protobuf, ProtobufSerializer::ProtobufAdapter)
  end

  it "serializes into Protobuf object" do
    serializer = Protobuf::Model::PermissionSerializer.new(permission)
    result = ProtobufSerializer::ProtobufAdapter.new(serializer).serializable_hash

    expect(result).to be_a_kind_of(Protobuf::Model::Permission)
    expect(result.admin).to eq(true)
  end


  it "serializes into Protobuf object with a collection inside" do
    serializer = Protobuf::Model::MembersSerializer.new(members)
    result = ProtobufSerializer::ProtobufAdapter.new(serializer).serializable_hash
    expect(result.members.first).to be_a_kind_of(Protobuf::Model::Member)
    expect(result.members.map(&:name)).to match_array(["NGUYEN", "TIEN"])
    expect(result.permission).to be_a_kind_of(Protobuf::Model::Permission)
    expect(result.flag).to eq("Read")
  end

  it "serializes empty object" do
    serializer = Protobuf::Model::MembersSerializer.new(empty_members)
    result = ProtobufSerializer::ProtobufAdapter.new(serializer).serializable_hash
    expect(result.members).to eq([])
    expect(result.permission).to eq(nil)
    expect(result.flag).to eq("Read")
  end
end
