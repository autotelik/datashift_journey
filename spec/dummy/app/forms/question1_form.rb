class  Question1Form < DatashiftJourney::BaseCollectorForm

  def params_key
    :question1
  end

  property :field_value
  validates :field_value, presence: true
end
