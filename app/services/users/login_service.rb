# typed: strict

require "dry/monads"

module Users
  class LoginService
    extend T::Sig

    include Dry::Monads[:result]

    attr_reader :params, :user

    sig { params(email: String, password: String).void }
    def initialize(email:, password:)
      @params = T.let({ email: email, password: password }, T::Hash[T.untyped, T.untyped])
    end

    sig { returns(Dry::Monads::Result) }
    def call
      find_user_by_email
        .bind { |user| authenticate_user(user) }
        .tee { |user|
        Rails.logger.info "Login successful for #{user.username}"
        Success()
      }
        .fmap do |user|
          @user = UserMapper.to_struct(user)
          @user
        end
        .or do |error_message|
          Rails.logger.error "Login failed: #{error_message}"
          Failure(error_message)
        end
    end

    sig { returns(Dry::Monads::Result) }
    def find_user_by_email
      user = User.find_by(email: params[:email])

      if user
        Success(user)
      else
        Failure("Invalid email or password")
      end
    end

    sig { params(user: User).returns(Dry::Monads::Result) }
    def authenticate_user(user)
      if user.authenticate(@params[:password])
        Success(user)
      else
        Failure("Invalid email or password")
      end
    end
  end
end
