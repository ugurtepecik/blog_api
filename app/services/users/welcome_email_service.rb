# typed: strict

require "dry/monads"

module Users
  class WelcomeEmailService
    extend T::Sig

    include Dry::Monads[:result]

    attr_reader :user

    def initialize(user_struct)
      @user = user_struct
    end

    sig { returns(Dry::Monads::Success) }
    def call
      Rails.logger.info "Welcome email"
      Success.new(true)
    end
  end
end
