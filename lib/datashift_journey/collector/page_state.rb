module DatashiftJourney
  module Collector

    # This stores details for rendering and storing a Page related to a single State, associated with state engine
    #
    class PageState < ActiveRecord::Base

      self.table_name = 'dsj_page_states'

      has_many :form_fields, dependent: :destroy

      has_many :data_nodes,
               through: :form_fields,
               class_name: 'CollectorDataNode',
               foreign_key: :page_state_id,
               dependent: :destroy

      has_many :page_state_snippets, foreign_key: :page_state_id

      has_many :snippets, through: :page_state_snippets # foreign_key: :page_state_id

      def header
        snippets.collect { |s| s.I18n_key.present? ? I18n.t(s.I18n_key) : s.raw_text }.join(' ')
      end

    end
  end
end
