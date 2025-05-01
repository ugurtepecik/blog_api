# typed: strict

module Errors
  class AuthenticationError < ApplicationError
    def initialize(message: "Invalid credentials")
      super(message: message, status: 401)
    end
  end
end
