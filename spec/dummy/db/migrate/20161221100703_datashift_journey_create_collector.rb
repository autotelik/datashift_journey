class DatashiftJourneyCreateCollector < ActiveRecord::Migration[6.1]

  # rubocop:disable Metrics/MethodLength

  def change

    create_table :dsj_form_definitions do |t|
      t.string :state, index: true, null: false
      t.string :klass, index: true, null: false
      t.timestamps null: false
    end

    create_table :dsj_form_fields do |t|
      t.references :form_definition, index: true, null: false
      t.string     :name, index: true,  null: false, limit: 100
      t.integer    :category, index: true, null: false
      t.jsonb      :options, null: false, default: {}
      t.timestamps null: false
    end

    add_index :dsj_form_fields, :options, using: :gin   # see GIN vs GiST

    # The plan is an instance of a JourneyPlan class
    create_table :dsj_data_nodes do |t|
      t.references  :plan,  null: false, polymorphic: true
      t.references  :form_field, null: false
      t.text        :field_value
      t.timestamps  null: false
    end

    create_table :dsj_snippets do |t|
      t.text        :raw_text
      t.string      :I18n_key, index: true
      t.timestamps  null: false
    end

    create_table :dsj_forms_snippets do |t|
      t.references  :form_model, null: false
      t.references  :snippet, null: false
    end

    create_table :dsj_fields_snippets do |t|
      t.references  :form_field, null: false
      t.references  :snippet, null: false
    end

  end
end
