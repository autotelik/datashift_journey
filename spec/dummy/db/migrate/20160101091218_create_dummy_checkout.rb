class CreateDummyCheckout < ActiveRecord::Migration
  def change

    # The standard format when workign with a Single state machine/class
    #
    create_table :checkouts do |t|
      t.string :state
      t.timestamps null: false
    end

    # For Rspec - Lots of different state machine classes required
    # - because the state machine Name must be reflected in the Column
    ["checkout_empties", "checkout_as","checkout_bs","checkout_cs","checkout_ds","checkout_es","checkout_fs", ].each do |c|
      create_table c do |t|
        t.string c.singularize
        t.timestamps null: false
      end
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
