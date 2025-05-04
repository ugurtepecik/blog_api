# typed: true

class UserStruct
  sig { returns(String) }
  def id; end

  sig { returns(String) }
  def username; end

  sig { returns(String) }
  def first_name; end

  sig { returns(String) }
  def last_name; end

  sig { returns(String) }
  def email; end

  sig { returns(Time) }
  def created_at; end

  sig { returns(Time) }
  def updated_at; end
end
