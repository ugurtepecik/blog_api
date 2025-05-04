# typed: true

class Rails::Application::Configuration
  sig { returns(T.nilable(Integer)) }
  def jwt_expiration_time; end
end
