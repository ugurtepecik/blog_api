# typed: true

require 'dry/monads'

module Api
  module V1
    class UsersController < ApplicationController
      extend T::Sig
      include Dry::Monads::Result::Mixin

      sig { void }
      def create
        signup
          .fmap do |user_struct|
          render_success(payload: UserBlueprint.render_as_hash(user_struct),
                         meta: LoginResponseBlueprint.render_as_hash({}))
        end
          .or do |error|
          render_error(error)
        end
      end

      private

      sig { returns(Dry::Monads::Result[Errors::ValidationError, UserStruct]) }
      def signup
        signup_params.bind do |validated_params|
          Users::SignupService.new(params: validated_params).call
        end
      end

      sig { returns(Dry::Monads::Result[Errors::ValidationError, T::Hash[Symbol, T.untyped]]) }
      def signup_params
        Users::SignupContract.new.call(params)
      end
    end
  end
end
