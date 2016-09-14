class Question1Form < DatashiftJourney::BaseCollectorForm

  def self.factory(journey)
    data_node = DatashiftJourney::DataNode.new(
      form_name: "Question1Form",
      field: "question_1",
      field_presentation: "Question 1",
      field_type: "string"
    )

    new(data_node, journey)
  end

  def params_key
    :question1
  end

  property :field_value
  validates :field_value, presence: true


end

