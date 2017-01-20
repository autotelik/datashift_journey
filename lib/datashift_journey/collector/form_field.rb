module DatashiftJourney
  module Collector

    # This stores a single Field in a Form, where a field is generally a form
    # element that collects some kind of data
    #
    class FormField < ActiveRecord::Base

      self.table_name = 'dsj_form_fields'

      belongs_to :page_state

      has_many :data_nodes, class_name: 'CollectorDataNode', foreign_key: :form_field_id, dependent: :destroy

      has_many :snippets, class_name: 'FieldSnippet', foreign_key: :form_field_id, dependent: :destroy
      has_many :snippets, class_name: 'FieldSnippet', foreign_key: :form_field_id, dependent: :destroy

      has_many :field_snippets, foreign_key: :form_field_id

      has_many :snippets, through: :field_snippets # , foreign_key: :page_state_id

      scope :for_form_and_field, ->(form_name, field_name) {
        page_state = PageState.where('form_name = ?', form_name).first
        return nil unless page_state
        page_state.form_fields.where('field = ?', field_name).first
      }

      def question
        Snippet.to_sentance(snippets)
      end

    end
  end
end
