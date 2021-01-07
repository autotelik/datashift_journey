module DatashiftJourney
  module Collector

    # This DEFINES a single Field in a Form, where a field is generally a form
    # element that collects some kind of data
    #
    class FormField < ActiveRecord::Base

      self.table_name = 'dsj_form_fields'

      belongs_to :form_definition, class_name: 'FormDefinition', foreign_key: :form_definition_id

      validates_presence_of :form_definition, :name, :category

      # Notes:
      #
      #  Cannot use "select" - keyword already defined by Active Record.
      #
      #   When assigning a category of - :select_option - the form should also provide a helper method
      #   to populate the select dropdown as per https://api.rubyonrails.org/v6.0.3.4/classes/ActionView/Helpers/FormOptionsHelper.html
      #
      #   The expected method format is : options_for_select_<field name>
      #
      #   So a field definition :
      #
      #       journey_plan_form_field name: :run_time, category: :select_option
      #
      #   Would also require a select dropdown helper method called options_for_select_run_time, for example,
      #   in our Form we could do something like:
      #
      #       def options_for_select_run_time
      #         options_for_select(run_times, run_times)
      #       end
      #
      #       private
      #
      #       def run_times
      #         @run_times ||= %w[PyTorch TensorFlow TensorRT]
      #       end
      #
      enum category: [:string, :select_option, :text_area, :number, :date, :radio_button ]
      #  :check_box, , password range date time datetime_local month week search email telephone url color }

      scope :for_form_and_field, ->(form_name, field_name) {
        page_state = DatashiftJourney::Collector::FormDefinition.where('state = ?', form_name).first
        return nil unless page_state
        page_state.form_fields.where('name = ?', field_name).first
      }

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
