module DatashiftJourney
  module Collector

    # This stores details for rendering and storing a Page related to a single State, associated with state engine
    #
    class PageState < ActiveRecord::Base

      self.table_name = 'dsj_page_states'

      has_many :form_fields, dependent: :destroy

      has_many :data_nodes,
               through: :form_fields,
               class_name: "CollectorDataNode",
               foreign_key: :form_id,
               dependent: :destroy


    end
  end
end
