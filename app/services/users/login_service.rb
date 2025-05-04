# typed: true

require 'dry/monads'

module Users
  class LoginService
    extend T::Sig

    include Dry::Monads::Result::Mixin

    attr_reader :params, :user

    sig { params(params: T::Hash[Symbol, T.untyped]).void }
    def initialize(params:)
      @params = params
    end

    sig { returns(Dry::Monads::Result[String, UserStruct]) }
    def call
      find_user_by_email
        .bind { |user| authenticate_user(user) }
        .tee do |user|
          Rails.logger.info "Login successful for #{user.username}"
          Success(user)
        end
        .fmap do |user|
          @user = UserMapper.to_struct(user)
          T.must(@user)
        end
        .or do |error_message|
          Rails.logger.error "Login failed: #{error_message}"
          Failure(error_message)
        end
    end

    sig { returns(Dry::Monads::Result[String, User]) }
    def find_user_by_email
      user = User.find_by(email: params[:email])

      if user
        Success(T.must(user))
      else
        Failure('Invalid email or password')
      end
    end

    sig { params(user: User).returns(Dry::Monads::Result[String, User]) }
    def authenticate_user(user)
      if user.authenticate(@params[:password])
        Success(user)
      else
        Failure('Invalid email or password')
      end
    end
  end
end
