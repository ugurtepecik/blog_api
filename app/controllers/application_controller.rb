# typed: strict

class ApplicationController < ActionController::API
  extend T::Sig

  private

  sig { params(payload: T::Hash[Symbol, T.untyped], meta: T::Hash[Symbol, T.untyped], status: Integer).void }
  def render_success(payload:, meta: nil, status: 200)
    if meta.nil?
      render json: { status: "success", data: payload }, status: status
    else
      render json: { status: "success", data: payload, meta: meta }, status: status
    end
  end

  sig { params(message: String, status: Integer).void }
  def render_error(message:, status: 400)
    render json: { status: "error", error: message }, status: status
  end
end
