class CreateDummyRegistration < ActiveRecord::Migration
  def change
    create_table :registrations do |t|
      t.string :name

      t.boolean :a_boolean
      t.string :some_string1
      t.text :some_text

      # These are real
      t.timestamps null: false
    end

    create_table :addresses do |t|
      t.string :premises,           limit: 200
      t.string :street_address,     limit: 160
      t.string :locality,           limit: 70
      t.string :city,               limit: 30
      t.string :postcode,           limit: 8
      t.string :country_iso,        limit: 3
      t.integer :address_type,      default: 0, null: false

      t.references :registration

      t.timestamps null: false
    end

  end
end
