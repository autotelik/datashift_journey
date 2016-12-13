module DatashiftJourney
  module Models
    class Collector < ActiveRecord::Base

      self.table_name = 'dsj_collectors'

      has_many :collector_data_nodes, foreign_key: :collector_id, dependent: :destroy

      # 1-1 with state
      has_many :forms

      has_many :form_fields, through: :collector_data_nodes

      has_many :data_nodes, through: :collector_data_nodes, dependent: :destroy

      def nodes_for_form_field(form_field)
        collector_data_nodes.find(form_field)
      end

    end
  end
end
