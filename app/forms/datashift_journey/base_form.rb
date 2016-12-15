require_dependency 'reform'

module DatashiftJourney

  class BaseForm < Reform::Form

    # include ActionView::Helpers::TranslationHelper
    include Reform::Form::ActiveModel::Validations

    # Hmmmm the reform ActiveModel::Validations include requires some odd stuff
    delegate :model_name, to: :model

    # def build_errors
    #  model.errors
    # end

    # Ok our stuff now

    attr_reader :journey_plan
    attr_accessor :redirection_url

    # Default factory when the form model == main journey plan model
    def self.factory(journey_plan)
      new(journey_plan)
    end

    # The form can  manage the main journey plan model and/or an associated model
    # for example Payment or Address collector associated with your main Checkout model.
    # To supply an associated model, your factory could look something like
    #
    #   def self.factory(checkout)
    #      address = Address.new(address_type: :billing)
    #      new(address, checkout)
    #   end
    #
    def initialize(model, journey_plan = nil)
      @journey_plan = journey_plan || model
      super(model)
    end

    def validate(params)
      Rails.logger.debug "VALIDATING #{model.inspect} - Params - #{form_params(params)}"
      super form_params(params)
    end

    def redirect?
      Rails.logger.debug "Checking for REDIRECTION - [#{redirection_url}]"
      !redirection_url.nil?
    end

    # Default is to display a submit button - which essentially calls our Controller and
    # moves the state forwards, if validate/save etc all pass
    # Individual forms/views may want to over ride, e.g at journey's end or to use their own buttons
    #
    def show_submit_button?
      true
    end

    protected

    def form_params(params)
      params.fetch(params_key, {})
    end

    def logger
      Rails.logger
    end

    # Class methods as used heavily from class method validation methods

    class << self
      def locale_key
        name.underscore
      end

      # Scope for locales that initially matches view scope
      def locale_errors
        # When called from a derived class DerivedForm - self.class.name = Class but self.name = DerivedForm
        "#{DatashiftJourney.journey_plan_class.name.tableize}.#{name.underscore}.errors"
      end
    end

  end

end
