# typed: true

require 'dry/monads'

module Users
  class SignupService
    extend T::Sig

    include Dry::Monads::Result::Mixin

    attr_reader :params, :user

    sig { params(params: T::Hash[Symbol, T.untyped]).void }
    def initialize(params:)
      @params = params
    end

    sig { returns(Dry::Monads::Result[Errors::ValidationError, UserStruct]) }
    def call
      puts @params
      user = User.new(@params)

      save_user(user)
        .tee do |user_struct|
          Users::WelcomeEmailService.new(user_struct).call
          Success(user_struct)
        end
        .fmap do |user_struct|
          Rails.logger.info("Signup success for #{user_struct.username}")
          @user = user_struct
          @user
        end
        .or do |errors|
          Rails.logger.error("Signup failed: #{errors}")
          Failure(errors)
        end
    end

    private

    sig { params(user: T.nilable(User)).returns(Dry::Monads::Result[Errors::ValidationError, UserStruct]) }
    def save_user(user)
      return fail_with_log('User is nil') if user.nil?

      if user.save
        handle_successful_save(user)
      else
        handle_failed_save(user)
      end
    end

    sig { params(user: User).returns(Dry::Monads::Result[Errors::ValidationError, UserStruct]) }
    def handle_successful_save(user)
      Rails.logger.info "User created successfully: #{user.username} (#{user.email})"
      user_struct = UserMapper.to_struct(user)
      return fail_with_log('User struct is nil') if user_struct.nil?

      Success(user_struct)
    end

    sig { params(user: User).returns(Dry::Monads::Result[Errors::ValidationError, UserStruct]) }
    def handle_failed_save(user)
      error_message = user.errors.full_messages.join(', ')
      Rails.logger.error "User signup failed: #{error_message}}"
      error = Errors::ValidationError.new(message: error_message)
      Failure(error)
    end

    sig { params(message: String).returns(Dry::Monads::Result[Errors::ValidationError, T.untyped]) }
    def fail_with_log(message)
      Rails.logger.error(message)
      Failure(Errors::ValidationError.new)
    end
  end
end
