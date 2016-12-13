class DatashiftJourneyCreateCollector < ActiveRecord::Migration
  def change

    # The Container - one per journey - in most situations this would belong to a user account
    # of person logged in and taking journey

    create_table :dsj_collectors do |t|
      t.string :state, index: true, null: false
      t.string :reference, index: true, unique: true, null: false
      t.timestamps null: false
    end

    create_table :dsj_form_fields do |t|
      t.string :form,  index: true,  null: false
      t.string :field, index: true,  null: false
      t.string :field_presentation, :limit => 100
      t.string :field_type,  null: false
      t.timestamps null: false
    end


    create_table :dsj_collectors_data_nodes do |t|
      t.references  :collector,  null: false
      t.references  :form_field, null: false
      t.text        :field_value
      t.timestamps  null: false
    end

    add_foreign_key :collectors_data_nodes, :dsj_collectors, column: :form_field_id

    add_index :dsj_collectors_data_nodes, [:collector_id, :form_field_id], unique: true,
              name: 'collectors_data_nodes_collector_id_form_field_id'

  end
end
