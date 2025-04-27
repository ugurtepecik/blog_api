class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users, id: :uuid do |t|
      t.string :username, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.string :password_digest, null: false

      t.timestamps precision: 6, default: -> { 'CURRENT_TIMESTAMP' }
    end
    add_index :users, :username, unique: true
    add_index :users, :email, unique: true
  end
end
