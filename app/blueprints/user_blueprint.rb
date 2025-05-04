# typed: true

class UserBlueprint < Blueprinter::Base
  identifier :id

  fields :username, :email, :first_name, :last_name
end
