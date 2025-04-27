# typed: strict

class UserMapper
  extend T::Sig

  sig { params(user: T.nilable(User)).returns(T.nilable(UserStruct)) }
  def self.to_struct(user)
    return nil if user.nil?

    UserStruct.new(
      id: user.id&.to_s,
      username: user.username,
      first_name: user.first_name,
      last_name: user.last_name,
      email: user.email,
      created_at: user.created_at,
      updated_at: user.updated_at
    )
  end

  sig { params(users: T::Array[User]).returns(T::Array[UserStruct]) }
  def self.collection_to_struct(users)
    users.map { |user| to_struct(user) }
  end
end
