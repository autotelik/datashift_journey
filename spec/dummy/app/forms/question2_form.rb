class Question2Form < DatashiftJourney::BaseCollectorForm

  def params_key
    :question2
  end

  property :field_value
  validates :field_value, presence: true


end

