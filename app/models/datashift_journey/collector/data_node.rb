module DatashiftJourney
  module Collector
    class DataNode < ActiveRecord::Base

      self.table_name = 'dsj_collector_data_nodes'

      # The DatashiftJourney.journey_plan_class - model holding the state machine Plan
      belongs_to :plan, polymorphic: true

      belongs_to :form_field, class_name: 'DatashiftJourney::Collector::FormField'

    end
  end
end
