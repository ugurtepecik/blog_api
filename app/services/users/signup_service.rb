# typed: strict

require "dry/monads"

module Users
  class SignupService
    extend T::Sig

    include Dry::Monads[:result]

    attr_reader :user

    sig { params(params: T::Hash[Symbol, T.untyped]).void }
    def initialize(params)
      @params = params
    end

    sig { returns(Dry::Monads::Result) }
    def call
      user = User.new(@params)

      save_user(user)
        .tee { |user| Users::WelcomeEmailService.new(user).call }
        .fmap { |user_struct|
          Rails.logger.info("Signup success for #{user_struct.username}")
          @user = user_struct
          @user
        }
        .or   { |errors|
          Rails.logger.error("Signup failed: #{errors.join(", ")}")
          Failure(errors)
        }
    end

    private

    sig { params(user: T.nilable(User)).returns(Dry::Monads::Result) }
    def save_user(user)
      if T.must(user).save
        Rails.logger.info "User created successfully: #{T.must(user).username} (#{T.must(user).email})"
        Success(UserMapper.to_struct(user))
      else
        Rails.logger.error "User signup failed: #{T.must(user).errors.full_messages.join(", ")}"
        Failure(T.must(user).errors.full_messages)
      end
    end
  end
end
