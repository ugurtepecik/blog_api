# typed: true

module Errors
  class UnknownError < ApplicationError
    def initialize(message: 'Unknown error')
      super(message: message, status: 422)
    end
  end
end
