class AddAuthenticationToHealthcareFacilities < ActiveRecord::Migration[8.0]
  def change
    add_column :healthcare_facilities, :password_digest, :string
  end
end
