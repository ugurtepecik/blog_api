# typed: strict

require "dry/validation"
require "dry/monads"

class ApplicationContract < Dry::Validation::Contract
  include Dry::Monads[:result]

  def call(params)
    result = super(params)

    wrap_result(result)
  end

  private

  def wrap_result(result)
    if result.success?
      Success(result.to_h)
    else
      error_message = result.errors(full: true).map(&:text).join(", ")
      Failure(error_message)
    end
  end
end
