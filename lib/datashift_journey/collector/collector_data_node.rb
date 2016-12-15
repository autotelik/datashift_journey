module DatashiftJourney
  module Collector
    class CollectorDataNode < ActiveRecord::Base

      self.table_name = 'dsj_collectors_data_nodes'

      belongs_to :collector
      belongs_to :form_field

    end
  end
end
