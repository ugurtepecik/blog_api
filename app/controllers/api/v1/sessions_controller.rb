# typed: true

require 'dry/monads'

module Api
  module V1
    class SessionsController < ApplicationController
      extend T::Sig
      include Dry::Monads::Result::Mixin

      sig { void }
      def create
        login
          .bind do |user_struct|
          generate_token(user_struct)
        end
          .fmap do |(user_struct, token)|
          render_success(payload: UserBlueprint.render_as_hash(user_struct),
                         meta: LoginResponseBlueprint.render_as_hash({ token: token }))
        end
          .or do |error|
          render_error(error)
        end
      end

      private

      sig { returns(Dry::Monads::Result[ApplicationError, UserStruct]) }
      def login
        login_params.bind do |validated_params|
          Users::LoginService.new(params: validated_params).call
        end
          .or do |error|
            case error
            in ApplicationError
              Failure(error)
            else
              Failure(Errors::AuthenticationError.new(message: error))
            end
          end
      end

      sig { returns(Dry::Monads::Result[Errors::ValidationError, T::Hash[Symbol, T.untyped]]) }
      def login_params
        Users::LoginContract.new.call(params)
      end

      sig { params(user_struct: UserStruct).returns(Dry::Monads::Result[Errors::UnknownError, [UserStruct, String]]) }
      def generate_token(user_struct)
        Jwt::JwtEncoder.encode({ user_id: user_struct.id })
          .fmap do |token|
          [user_struct, token]
        end
          .or do
          Failure(Errors::UnknownError.new)
        end
      end
    end
  end
end
