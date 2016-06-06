require_dependency "reform"

module DatashiftJourney

  class BaseForm < Reform::Form
    include ActionView::Helpers::TranslationHelper
    include ActiveModel::Validations

    feature Reform::Form::ActiveModel::Validations

    include BaseFormCommon
    extend BaseFormCommon

    def redirect?
      false
    end

    # Default to the url as defined in the view/partial but provide opportunity for Forms to
    # wire up the continue button as they see require
    def url
      nil
    end

    def initialize(model, journey_plan = nil)
      @journey_plan = journey_plan || model
      super(model)
    end

    def validate(params)
      super params.fetch(params_key) { {} }
    end

    attr_reader :journey_plan

    protected

    def logger
      Rails.logger
    end
  end
end
