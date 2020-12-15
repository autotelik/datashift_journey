require_dependency 'reform'

module DatashiftJourney

  # Collection of tools to support the Forms
  module FormMixin

    extend ActiveSupport::Concern

    attr_reader :journey_plan
    attr_accessor :redirection_url

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

    class_methods do
      def form_definition
        # In this situation self is the class of the including form eg PaymentForm, AddressFrom
        @form_definition ||= DatashiftJourney::Collector::FormDefinition.find_or_create_by!(klass: self.name)
      end

      # TODO: define valid list of category
      #
      def journey_plan_form_field(name:, category:)
        DatashiftJourney::Collector::FormField.find_or_create_by!(form_definition: form_definition, name: name,  category: category)
      end
    end

    protected

    def form_params(params)
      params.fetch(params_key, {})
    end

    def logger
      Rails.logger
    end

    def form_definition
      @form_definition ||= self.class.form_definition
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
