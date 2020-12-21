require_dependency 'reform'

module DatashiftJourney

  # Collection of tools to support the Forms
  module FormMixin

    extend ActiveSupport::Concern

    # These forms are used to back Views so need to be able to prepare and present data for views
    include ActionView::Helpers::FormOptionsHelper

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

    class_methods do

      def form_definition
        # In this situation self is the class of the including form eg PaymentForm, AddressFrom
        begin
          @form_definition ||= DatashiftJourney::Collector::FormDefinition.find_or_create_by(klass: self.name)
        rescue
          Rails.logger.error "Could not find or create FormDefinition [#{x}]"
          nil
        end
      end

      # Form helper to add fields inside a class definition
      #
      # N.B Currently this will create a permanent entry in the DB,
      # so removing this code will not remove the Field - must be deleted from DB
      #
      # Usage
      #
      #   journey_plan_form_field name: :model_uri, category: :string
      #   journey_plan_form_field name: :run_time,  category: :select_option
      #   journey_plan_form_field name: :memory,    category: :number
      #
      def journey_plan_form_field(name:, category:)
        begin
        DatashiftJourney::Collector::FormField.find_or_create_by!(form_definition: form_definition, name: name,  category: category)
        rescue => x
          Rails.logger.error "Could not find or create FormField [#{x}]"
          nil
        end
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

  end
end
