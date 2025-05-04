# typed: false

require 'dry-validation'
require 'uri'

module Users
  class LoginContract < ApplicationContract
    extend T::Sig
    include Dry::Monads::Result::Mixin

    params do
      required(:email).filled(:string, format?: URI::MailTo::EMAIL_REGEXP)
      required(:password).filled(:string, min_size?: 6)
    end

    sig do
      params(params: ActiveSupport::HashWithIndifferentAccess)
        .returns(Dry::Monads::Result[Errors::ValidationError, ActiveSupport::HashWithIndifferentAccess])
    end
    def call(params)
      result = super

      case result
      in Success(_)
        result
      in Failure(message)
        Failure(::Errors::ValidationError.new(message: message))
      end
    end
  end
end
