class CreateDummyCheckout < ActiveRecord::Migration
  def change
    create_table :checkouts do |t|
      t.string :state
      t.timestamps null: false
    end

    create_table :addresses do |t|
      t.string :premises,           limit: 200
      t.string :street_address,     limit: 160
      t.string :locality,           limit: 70
      t.string :city,               limit: 30
      t.string :postcode,           limit: 8
      t.string :country_iso,        limit: 3
      t.timestamps null: false
    end

    create_table :payments do |t|
      t.string :name
      t.string :card
      t.timestamps null: false
    end

    add_reference :checkouts, :bill_address,index: true
    add_reference :checkouts, :ship_address, index: true
    add_reference :checkouts, :payments, index: true

  end
end
