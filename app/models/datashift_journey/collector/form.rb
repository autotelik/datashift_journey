module DatashiftJourney
  module Collector

    # This stores details for rendering and storing data on a Form
    # related to a single State
    #
    class Form < ActiveRecord::Base

      validates_presence_of :form_name

      self.table_name = 'dsj_forms'

      has_many :form_fields, class_name: 'DatashiftJourney::Collector::FormField', dependent: :destroy

      has_many :data_nodes,
               through: :form_fields,
               class_name: 'DatashiftJourney::Collector::DataNode',
               foreign_key: :page_state_id,
               dependent: :destroy

      has_many :page_state_snippets, foreign_key: :page_state_id

      has_many :snippets, through: :page_state_snippets # foreign_key: :page_state_id

      def header
        Snippet.to_sentance(snippets)
      end

    end
  end
end
