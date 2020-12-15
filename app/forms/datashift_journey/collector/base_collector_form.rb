require_relative '../concerns/form_mixin'

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

      include DatashiftJourney::FormMixin

      feature Reform::Form::Dry # override the default.

      attr_accessor :definition

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
        # If this page already been visited we should have completed data nodes already
        form_definition.form_fields.map(&:id).each do |id|
          next if journey_plan.data_nodes.where('form_field_id = ?', id).exists?
          journey_plan.data_nodes << DatashiftJourney::Collector::DataNode.new(plan: journey_plan, form_field_id: id)
        end

      end

    end
  end
end
