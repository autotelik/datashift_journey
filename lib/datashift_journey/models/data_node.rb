module DatashiftJourney
  module Models
    # This stores a single Field from a Form
    #
    class DataNode < ActiveRecord::Base

      self.table_name = 'dsj_data_nodes'

    end
  end
end
