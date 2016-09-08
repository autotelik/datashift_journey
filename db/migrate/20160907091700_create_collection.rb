class CreateCollection < ActiveRecord::Migration
  def change

    # The Container - one per journey - in most situations this would belong to a user account
    # of person logged in and taking journey
    
    create_table :datashift_journey_collectors do |t|
      t.string :state, index: true, unique: true
      t.string :reference, index: true, unique: true
      t.timestamps null: false
    end
    
    create_table :datashift_journey_data_nodes do |t|
      t.string :form_name, index: true
      t.string :field, index: true
      t.string :field_presentation, :limit => 100
      t.string :field_type
      t.text :field_value
      t.timestamps null: false
    end

    create_table :datashift_journey_collectors_data_nodes do |t|
      t.references  :collector,  null: false
      t.references  :data_node,  null: false
      t.integer    :position
    end

    add_foreign_key :collectors_data_nodes, :datashift_journey_collectors, column: :data_node_id

    add_index :datashift_journey_collectors_data_nodes, [:collector_id, :data_node_id], unique: true,
              name: 'collectors_data_nodes_collector_id_data_node_id'

  end
end
