class AddAuthenticationToDoctors < ActiveRecord::Migration[8.0]
  def change
    add_column :doctors, :email, :string
    add_index :doctors, :email, unique: true
    add_column :doctors, :password_digest, :string
  end
end
