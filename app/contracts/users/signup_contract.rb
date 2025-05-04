# typed: false

require 'dry-validation'
require 'uri'

module Users
  class SignupContract < ApplicationContract
    extend T::Sig
    include Dry::Monads::Result::Mixin

    def self.key?(key)
      %i[username password email first_name last_name].include?(key)
    end

    params do
      required(:username).filled(:string, min_size?: 6)
      required(:password).filled(:string, min_size?: 6)
      required(:email).filled(:string, format?: URI::MailTo::EMAIL_REGEXP)
      required(:last_name).filled(:string)
      required(:first_name).filled(:string)
    end

    sig do
      params(params: ActionController::Parameters)
        .returns(Dry::Monads::Result[Errors::ValidationError, T::Hash[Symbol, T.untyped]])
    end
    def call(params)
      sanitize(params)
        .bind do |sanitized|
          super(sanitized)
        end
    end

    private

    sig do
      params(params: ActionController::Parameters)
        .returns(Dry::Monads::Result[Errors::ValidationError, T::Hash[Symbol, T.untyped]])
    end
    def sanitize(params)
      sanitized = params.require(:user).permit!.to_h
      Success(sanitized)
    rescue StandardError => e
      Failure(Errors::ValidationError.new(message: e.message))
    end
  end
end
