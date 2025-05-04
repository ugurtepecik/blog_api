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

      sig { returns(Dry::Monads::Result[Errors::AuthenticationError, UserStruct]) }
      def login
        Users::LoginService.new(
          email: login_params[:email],
          password: login_params[:password]
        ).call
          .or do |error_message|
          Failure(Errors::AuthenticationError.new(message: error_message))
        end
      end

      sig { returns(ActionController::Parameters) }
      def login_params
        params.require(:user).permit(:email, :password)
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
