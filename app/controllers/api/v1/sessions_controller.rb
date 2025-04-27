# typed: strict

require "dry/monads"

module Api
  module V1
    class SessionsController < ApplicationController
      extend T::Sig
      include Dry::Monads[:result]

      sig { void }
      def create
        Users::LoginService.new(
          email: login_params[:email],
          password: login_params[:password]
        )
        .call
        .bind { |user_struct| generate_token(user_struct)
        }
        .fmap { | (user_struct, token) |
        puts token
          render_success(payload: UserBlueprint.render_as_hash(user_struct), meta: LoginResponseBlueprint.render_as_hash({ token: token }))
        }
        .or { |error_message|
          render_error(message: error_message, status: determine_error_status(error_message))
        }
      end

      private

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
      end

      sig { params(error_message: String).returns(Integer) }
      def determine_error_status(error_message)
        error_message.include?("Invalid email or password") ? 401 : 500
      end
    end
  end
end
