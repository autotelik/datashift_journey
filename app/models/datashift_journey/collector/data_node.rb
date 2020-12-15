module DatashiftJourney
  module Collector
    class DataNode < ActiveRecord::Base

      self.table_name = 'dsj_data_nodes'

      # Instance of the DatashiftJourney.journey_plan_class this data was collected for.
      #
      # Model holding the state machine Plan
      belongs_to :plan, polymorphic: true

      # generic definition of the field this data relates to - card type, street address, profile id etc
      belongs_to :form_field, class_name: 'DatashiftJourney::Collector::FormField', foreign_key: :form_field_id

      validates_presence_of :field_value
    end
  end
end
