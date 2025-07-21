class AddAuthenticationToPatients < ActiveRecord::Migration[8.0]
  def change
    add_column :patients, :password_digest, :string
  end
end
