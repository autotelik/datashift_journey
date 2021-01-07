module DatashiftJourney
  module Collector
    module PlanConcern

      # include in your model to add data collection nodes, that can be auto populated with form data
      #
      #   include DatashiftJourney::Collector::PlanConcern
      #
      # See  generator : lib/generators/datashift_journey/collector/collector_generator.rb
      #
      extend ActiveSupport::Concern

      included do
        has_many :data_nodes, class_name: 'DatashiftJourney::Collector::DataNode', as: :plan, foreign_key: :plan_id, dependent: :destroy
        accepts_nested_attributes_for :data_nodes
      end

      def data_to_hash
        hash = {}.with_indifferent_access
        self.data_nodes.each { |node| hash[node.form_field.name] = node.field_value }
        hash
      end

      def data_node_on_field(name:)
        ff = DatashiftJourney::Collector::FormField.where(name: name).first
        return nil if ff.blank?

        DatashiftJourney::Collector::DataNode.where(plan_type: self.class.name, plan_id: self.id, form_field_id: ff.id).last
      end

      # Hook available after last state passed, but before the show JourneyEnd view is rendered.
      def on_journey_end
      end

    end
  end
end
