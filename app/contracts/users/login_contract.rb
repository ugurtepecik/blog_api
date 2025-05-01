# typed: strict

require "dry-validation"
require "uri"

module Users
  class LoginContract < ApplicationContract
    include Dry::Monads[:result]

    params do
      required(:email).filled(:string, format?: URI::MailTo::EMAIL_REGEXP)
      required(:password).filled(:string, min_size?: 6)
    end

    def call(params)
      result = super(params)

      case result
      in Success(_)
        result
      in Failure(message)
        Failure(::Errors::ValidationError.new(message: message))
      end
    end
  end
end
