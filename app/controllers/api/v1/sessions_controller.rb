# typed: strict

require "dry/monads"

module Api
  module V1
    class SessionsController < ApplicationController
      extend T::Sig
      include Dry::Monads[:result]

      sig { void }
      def create
        Users::LoginContract.new.call(login_params.to_h)
        .bind { |params| login(params) }
        .bind { |user_struct| generate_token(user_struct)
        }
        .fmap { | (user_struct, token) |
          render_success(payload: UserBlueprint.render_as_hash(user_struct), meta: LoginResponseBlueprint.render_as_hash({ token: token }))
        }
        .or { |error|
        render_error(error)
      }
      end

      private

      def login(params)
          Users::LoginService.new(
            email: params[:email],
            password: params[:password]
          ).call()
          .or { |error_message|
             Failure(Errors::AuthenticationError.new(message: error_message))
          }
      end

      sig { returns(ActionController::Parameters) }
      def login_params
        params.require(:user).permit(:email, :password)
      end

      sig { params(user_struct: UserStruct).returns(Dry::Monads::Result) }
      def generate_token(user_struct)
        Jwt::JwtEncoder.encode({ user_id: user_struct.id })
        .fmap {
          |token|  [ user_struct, token ]
        }
        .or {
          Failure(Error::UnknownError.new())
        }
      end
    end
  end
end
