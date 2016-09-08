class PageOneForm < DatashiftJourney::BaseForm

  def params_key
    :page_one
  end

  property :name, virtual: true

  validates :name, presence: { message: "oh dear please provide a node" }

  def save
    node = DatashiftJourney::DataNode.new

    puts "MODEL :", model.inspect

    # t.string :form_name, index: true
    # t.string :field, index: true
    # t.string :field_presentation, :limit => 100
    # t.string :field_type
    # t.text :field_value
    # t.timestamps null: false

    true
  end

end
