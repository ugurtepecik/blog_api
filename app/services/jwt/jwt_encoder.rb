# typed: strict

require "jwt"
require "dry/monads"

module Jwt
  SECRET_KEY = T.let(
    Rails.application.credentials.jwt_secret || "default_secret_key", String
  )

  ALGORITHM = T.let("HS256", String)

  class JwtEncoder
    extend T::Sig
    extend Dry::Monads[:result]

    EXPIRATION_TIME = T.let((Rails.application.config.jwt_expiration_time || 24).hours.to_i, Integer)

    sig { params(payload: T::Hash[Symbol, T.untyped]).returns(Dry::Monads::Result) }
    def self.encode(payload)
      payload_with_exp = payload.merge(
        exp: Time.now.to_i + EXPIRATION_TIME
      )

      token = JWT.encode(payload_with_exp, SECRET_KEY, ALGORITHM)

      Success(token)
    rescue StandardError => e
      Failure("JWT Encpding failed: #{e.message}")
    end
  end

  class JwtDecoder
    extend T::Sig
    extend Dry::Monads[:result]

    sig { params(token: String).returns(Dry::Monads::Result) }
    def self.decode(token)
      decoded_token = JWT.decode(token, SECRET_KEY, true, { algorithm: ALGORITHM })
      payload = decoded_token.first
      Success(payload)
    rescue JWT::ExpiredSignature
      Failure("Token has expired")
    rescue JWT::DecodeError => e
      Failure("Invalid token: #{e.message}")
    rescue StandardError => e
      Failure("Unknown decoding error: #{e.message}")
    end
  end
end
