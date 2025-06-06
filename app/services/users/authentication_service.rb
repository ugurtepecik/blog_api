# typed: true

require 'dry/monads'

module Users
  class AuthenticationService
    extend T::Sig

    include Dry::Monads::Result::Mixin

    sig { params(headers: ActionDispatch::Http::Headers).void }
    def initialize(headers)
      @headers = T.let(headers, ActionDispatch::Http::Headers)
    end

    sig { returns(Dry::Monads::Result[String, UserStruct]) }
    def call
      extract_token
        .bind { |token| Jwt::JwtDecoder.decode(token) }
        .bind { |payload| find_user(payload) }
    end

    private

    sig { returns(Dry::Monads::Result[String, String]) }
    def extract_token
      authorization_header = @headers['Authorization']

      return Failure('Missing Authorization Header') if authorization_header.nil?

      token = authorization_header.split.last

      return Failure('Invalid Authorization Header Format') if token.nil? || token.empty?

      Success(token)
    end

    sig { params(payload: T::Hash[String, T.untyped]).returns(Dry::Monads::Result[String, UserStruct]) }
    def find_user(payload)
      user_id = payload['user_id']

      return Failure('Invalid payload: missing user_id') if user_id.nil?

      user = User.find_by(id: user_id)
      user_struct = UserMapper.to_struct(user)

      return Failure('User not found') if user.nil? || user_struct.nil?

      Success(UserMapper.to_struct(user))
    end
  end
end
