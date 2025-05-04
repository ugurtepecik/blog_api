# typed: true

module Errors
  class ValidationError < ApplicationError
    def initialize(message: 'Validation failed')
      super(message: message, status: 422)
    end
  end
end
