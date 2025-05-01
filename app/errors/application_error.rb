# typed: strict

class ApplicationError < StandardError
  extend T::Sig

  sig { returns(String) }
  attr_reader :message

  sig { returns(Integer) }
  attr_reader :status

  sig { params(message: String, status: Integer).void }
  def initialize(message: "", status: 400)
    @status = T.let(status, Integer)
    @message = T.let(message, String)
    super(message)
  end
end
