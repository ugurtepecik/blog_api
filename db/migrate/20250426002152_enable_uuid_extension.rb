class EnableUuidExtension < ActiveRecord::Migration[8.0]
  def change
    enable_extension 'uuid-ossp'
  end
end
