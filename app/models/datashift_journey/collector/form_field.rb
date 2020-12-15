module DatashiftJourney
  module Collector

    # This DEFINES a single Field in a Form, where a field is generally a form
    # element that collects some kind of data
    #
    class FormField < ActiveRecord::Base

      self.table_name = 'dsj_form_fields'

      belongs_to :form_definition, class_name: 'FormDefinition', foreign_key: :form_definition_id

      validates_presence_of :form_definition, :name, :category

      scope :for_form_and_field, ->(form_name, field_name) {
        page_state = DatashiftJourney::Collector::FormDefinition.where('state = ?', form_name).first
        return nil unless page_state
        page_state.form_fields.where('name = ?', field_name).first
      }

      # TODO: Validate category is one of
      # :string, :select, check_box, radio_button, text_area
      #  password number range date time datetime_local month week search email telephone url color

      # TODO - revisit snippets
      #
      # many :snippets, class_name: 'FieldSnippet', foreign_key: :form_field_id, dependent: :destroy
      # has_many :field_snippets, foreign_key: :form_field_id
      # has_many :snippets, through: :field_snippets # , foreign_key: :page_state_id
      # def question
      #   Snippet.to_sentance(snippets)
      # end

    end
  end
end
