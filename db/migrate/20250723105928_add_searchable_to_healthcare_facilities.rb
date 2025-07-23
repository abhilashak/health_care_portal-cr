class AddSearchableToHealthcareFacilities < ActiveRecord::Migration[8.0]
  def change
    add_column :healthcare_facilities, :searchable, :tsvector

    # Add GIN index for fast full-text search
    add_index :healthcare_facilities, :searchable, using: :gin

    # Create trigger to automatically update searchable column
    execute <<-SQL
      CREATE TRIGGER healthcare_facilities_searchable_update
        BEFORE INSERT OR UPDATE ON healthcare_facilities
        FOR EACH ROW EXECUTE FUNCTION
        tsvector_update_trigger(
          searchable,
          'pg_catalog.english',
          name,
          address,
          description
        );
    SQL

    # Update existing records
    execute <<-SQL
      UPDATE healthcare_facilities SET searchable =#{' '}
        to_tsvector('pg_catalog.english',#{' '}
          coalesce(name, '') || ' ' ||
          coalesce(address, '') || ' ' ||
          coalesce(description, '')
        );
    SQL
  end

  def down
    execute "DROP TRIGGER IF EXISTS healthcare_facilities_searchable_update ON healthcare_facilities"
    remove_index :healthcare_facilities, :searchable
    remove_column :healthcare_facilities, :searchable
  end
end
