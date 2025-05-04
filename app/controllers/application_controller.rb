# typed: true

class ApplicationController < ActionController::API
  extend T::Sig

  private

  sig { params(payload: T::Hash[Symbol, T.untyped], meta: T.nilable(T::Hash[Symbol, T.untyped]), status: Integer).void }
  def render_success(payload:, meta: nil, status: 200)
    if meta.nil?
      render json: { status: 'success', data: payload }, status: status
    else
      render json: { status: 'success', data: payload, meta: meta }, status: status
    end
  end

  sig { params(error: ApplicationError).returns(T.untyped) }
  def render_error(error)
    render json: { status: 'error', error: error.message }, status: error.status
  end
end
