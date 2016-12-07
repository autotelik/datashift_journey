module DatashiftJourney
  module Models
  class CollectorDataNode < ActiveRecord::Base

    self.table_name = 'dsj_collectors_data_nodes'

    belongs_to :collector
    belongs_to :data_node

  end
end
