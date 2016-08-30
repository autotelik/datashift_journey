require_dependency "reform"

module DatashiftJourney

  class BaseForm < Reform::Form

    include ActionView::Helpers::TranslationHelper
    include ActiveModel::Validations

    feature Reform::Form::ActiveModel::Validations

    attr_reader :journey_plan
    attr_accessor :redirection_url

    def initialize(model, journey_plan = nil)
      @journey_plan = journey_plan || model
      super(model)
    end

    def validate(params)
      Rails.logger.debug "VALIDATING #{self} - Params - [#{form_params(params)}]"
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

=begin
    def locale_key
      Rails.logger.debug "SELF #{self}"
      self.class.locale_key
    end

    def locale_errors
      Rails.logger.debug "SELF #{self}"
      self.class.locale_errors
    end
=end

    # Class methods as used heavily from class method validation methods

    def self.locale_key
      self.name.underscore
    end

    def self.locale_errors
      # When called from a derived class DerivedForm - self.class.name = Class but self.name = DerivedForm
      "#{self.name.underscore}.errors"
    end

    def logger
      Rails.logger
    end
  end

end
