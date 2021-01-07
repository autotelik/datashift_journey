module DatashiftJourney
  module Collector

    # This class represents the View backing Form
    #
    # Reform API :
    #
    #   initialize always requires a model that the form represents.
    #   validate(params) updates the form's fields with the input data (only the form, not the model) and then runs all validations. The return value is the boolean result of the validations.
    #   errors returns validation messages in a classic ActiveModel style.
    #   sync writes form data back to the model. This will only use setter methods on the model(s).
    #   save (optional) will call #save on the model and nested models. Note that this implies a #sync call.
    #   prepopulate! (optional) will run pre-population hooks to "fill out" your form before rendering.
    #
    class BaseCollectorForm < Reform::Form

      # These forms are used to back Views so need to be able to prepare and present data for views
      include ActionView::Helpers::FormOptionsHelper

      feature Reform::Form::Dry # override the default.

      attr_accessor :definition, :journey_plan, :redirection_url

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
      def self.journey_plan_form_field(name:, category:)
        begin
          form_definition = DatashiftJourney::Collector::FormDefinition.where(klass: self.name).first
          DatashiftJourney::Collector::FormField.find_or_create_by!(form_definition: form_definition, name: name,  category: category)
        rescue => x
          Rails.logger.error "Could not find or create FormField [#{x}]"
          nil
        end
      end

      # Called from CONTROLLER
      #
      # Creates a form object backed by the current Plan object
      #
      # Data is collected generically from fields defined by FormDefinition and stored
      # in data nodes associated with current JourneyPlan instance (through polymorphic plan association)
      #
      def initialize(journey_plan)
        super(journey_plan)

        @journey_plan = journey_plan

        @definition = DatashiftJourney::Collector::FormDefinition.where(klass: self.class.name).first

        # For brand new forms, add one data node per form field - data nodes hold the COLLECTED VALUES
        # If this page already been visited we should have a completed data node already
        definition.form_fields.map(&:id).each do |id|
          next if journey_plan.data_nodes.where('form_field_id = ?', id).exists?
          journey_plan.data_nodes << DatashiftJourney::Collector::DataNode.new(plan: journey_plan, form_field_id: id)
        end

      end

      # Currently saved Data nodes for THIS Form
      def data_nodes
        definition.data_nodes(journey_plan)
      end

      # Returns ALL saved Data nodes collected AFTER this form
      # For example, when allowing users to go back to a branching split point, may want to clear all data collected
      # after that branch, as User may now choose a different branch
      #
      def subsequent_data_nodes
        DatashiftJourney::Collector::DataNode.where(plan: journey_plan).where("id > :id", id: last_node_id)
      end

      # Returns the ID of the last DataNode collected for THIS forms field(s)
      def last_node_id
        data_nodes.maximum(:id)
      end

      def redirect?
        Rails.logger.debug "Checking for REDIRECTION - [#{redirection_url}]"
        !redirection_url.nil?
      end

      def save(params)
        form_params = params.fetch(params_key, {})

        data_nodes = form_params["data_nodes"] # =>{"form_field"=>{"0"=>"name", "1"=>"namespace"}, "field_value"=>{"0"=>"dfsdf", "1"=>"ghfghf"}}}

        if data_nodes.present?
          fields = data_nodes["form_field"]
          values = data_nodes["field_value"]

          fields.each do |idx, name|
            ff = Collector::FormField.where(name: name, form_definition: definition).first
            next unless ff

            # Ensure when user goes back and changes a value we reflect the changed value
            Collector::DataNode.find_or_initialize_by(plan: journey_plan, form_field: ff).tap do |node|
              node.field_value = values[idx]
              node.save
            end
          end
        end
      end

      # Over ride in your form if your view forms have non standard key field.
      #
      # The default naming format for form elements in the view is : "#{params_key}[data_nodes][field_value][#{i}]"
      #
      # For example:
      #   <%= select_tag "#{params_key}[data_nodes][field_value][#{i}]"....  %>
      def params_key
        DatashiftJourney::FormObjectFactory.state_name(self.class.name)
      end

      def form_params(params)
        params.fetch(params_key, {})
      end

      # TODO: validation needs some thought/work in relation to now using generic Collector::DataNode
      def validate(params)
        Rails.logger.debug "VALIDATING #{model.inspect} - Params - #{form_params(params)}"
        super form_params(params)
      end
    end
  end
end
