module DatashiftJourney

  # This handles collecting data from a Form
  #
  class DataNode < ActiveRecord::Base

    self.table_name = "dsj_data_nodes"

  end

end
