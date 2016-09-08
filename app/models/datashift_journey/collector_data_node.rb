class CollectorDataNode < ActiveRecord::Base

  self.table_name = "collectors_data_nodes"

  belongs_to :collector
  belongs_to :data_node

end
