module DatashiftJourney
  module Models
    class Collector < ActiveRecord::Base

      self.table_name = 'dsj_collectors'

      has_many :collector_data_nodes, foreign_key: :collector_id, dependent: :destroy

      has_many :form_fields, through: :collector_data_nodes

      def node_for_form_and_field(form_name, field_name)
        form_field = FormField.for_form_and_field(form_name, field_name)
        collector_data_nodes.where(form_field: form_field).first
      end

      def nodes_for_form_field(form_field)
        collector_data_nodes.find(form_field).all
      end

    end
  end
end
