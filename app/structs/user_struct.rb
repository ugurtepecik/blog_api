# typed: strict

require "dry-struct"
require "dry-types"

module Types
  include Dry.Types
end

class UserStruct < Dry::Struct
  attribute :id, Types::String
  attribute :username, Types::String
  attribute :first_name, Types::String
  attribute :last_name, Types::String
  attribute :email, Types::String
  attribute :created_at, Types::Params::Time
  attribute :updated_at, Types::Params::Time
end
