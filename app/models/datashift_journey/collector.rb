module DatashiftJourney

  class Collector < ActiveRecord::Base

    self.table_name = "dsj_collectors"

    has_many :collector_data_nodes, foreign_key: :collector_id, dependent: :destroy

    has_many :data_nodes, through: :collector_data_nodes, dependent: :destroy

  end

end
