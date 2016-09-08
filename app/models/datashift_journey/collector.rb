module DatashiftJourney

  class Collector < ActiveRecord::Base
    
   # has_many :collector_data_nodes, foreign_key: :collector_id, dependent: :restrict_with_exception

  #  has_many :data_nodes, through: :collector_data_nodes, dependent: :restrict_with_exception

  end

end
