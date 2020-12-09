require_relative '../base_form'

module DatashiftJourney
  module Collector
    class BaseCollectorForm < DatashiftJourney::BaseForm

      collection :data_nodes do
        property :field_value
      end

      # Build DB structures to hold the data we collect as we traverse the Plan
      #
      def self.factory(journey_plan)
        collector_form = find_or_create_collector_form

        create_missing_collector_field(collector_form) if collector_form.form_fields.empty?

        form_fields = collector_form.form_fields

        # This assumes the journey_plan model has been decorated with - include DatashiftJourney::Collector
        #
        # Add one data node per form field - data nodes hold the COLLECTED VALUES

        puts '\nCREATING DATA NODES'
        pp journey_plan.data_nodes
        pp journey_plan
        form_fields.collect { |ff| pp ff ; journey_plan.data_nodes.build(plan: journey_plan, form_field: ff) }

        puts '\nForm CREATED', collector_form, journey_plan
        new(collector_form, journey_plan)
      end

      alias_attribute :collector, :journey_plan

      # Convention is a database Collector Form with same name as this view's Form class
      def self.collector_form_name
        name.chomp('Form')
      end

      def self.find_or_create_collector_form
        Collector::Form.where(form_name: collector_form_name).first_or_create
      end

      def self.create_missing_collector_field(form_object)
        Collector::FormField.create(form: form_object,
                                    field: collector_form_name.underscore,
                                    field_type: :string)
      end

    end
  end
end
