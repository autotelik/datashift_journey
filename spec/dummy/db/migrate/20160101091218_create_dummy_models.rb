class CreateDummyModels < ActiveRecord::Migration[6.1]
  def change

    mod = "datashift_journey"

    create_table :test_plan_models do |t|
      t.string :state
      t.string :reference

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

    create_table "#{mod}_payments" do |t|
      t.string :name
      t.string :card
      t.timestamps null: false
    end

    create_table "#{mod}_checkouts" do |t|
      t.string :state                 # The standard format when working with a Single state machine/class
      t.timestamps null: false
      t.string :token
      t.references :bill_address,index: true
      t.references :ship_address, index: true
      t.references :payment, index: true
    end


    # For Rspec - Lots of different state machine classes required
    # - because the state machine Name must be reflected in the Column

    ["checkout_empties", "checkout_as","checkout_bs","checkout_cs","checkout_ds","checkout_es","checkout_fs", ].each do |c|
      create_table "#{mod}_#{c}" do |t|
        t.string c.singularize
        t.timestamps null: false
      end
    end

  end
end
