# typed: true

class Dry::Monads::Result
  extend T::Generic

  FailureType = type_member
  SuccessType = type_member

  sig do
    type_parameters(:U, :F)
      .params(
        blk: T.proc.params(arg0: SuccessType).returns(Dry::Monads::Result[T.type_parameter(:F), T.type_parameter(:U)])
      )
      .returns(Dry::Monads::Result[T.any(FailureType, T.type_parameter(:F)), T.type_parameter(:U)])
  end
  def bind(&blk); end

  sig do
    type_parameters(:U)
      .params(blk: T.proc.params(arg0: SuccessType).returns(T.type_parameter(:U)))
      .returns(Dry::Monads::Result[FailureType, T.type_parameter(:U)])
  end
  def fmap(&blk); end

  sig do
    params(blk: T.proc.params(arg0: SuccessType).returns(T.untyped))
      .returns(Dry::Monads::Result[FailureType, SuccessType])
  end
  def tee(&blk); end

  sig do
    type_parameters(:U)
      .params(blk: T.proc.params(arg0: FailureType).returns(Dry::Monads::Result[T.type_parameter(:U), SuccessType]))
      .returns(Dry::Monads::Result[T.type_parameter(:U), SuccessType])
  end
  def or(&blk); end

  sig do
    params(
      success_block: T.nilable(T.proc.params(arg0: SuccessType).returns(T.untyped)),
      failure_block: T.nilable(T.proc.params(arg0: FailureType).returns(T.untyped))
    ).returns(T.untyped)
  end
  def either(success_block = nil, failure_block = nil); end

  sig { returns(T.untyped) }
  def value!; end

  sig { params(_default: T.untyped).returns(T.untyped) }
  def value_or(_default); end

  sig { returns(T::Boolean) }
  def success?; end

  sig { returns(T::Boolean) }
  def failure?; end

  sig { returns(T.untyped) }
  def failure; end

  sig { returns(T.untyped) }
  def to_maybe; end
end
