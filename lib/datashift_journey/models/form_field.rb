module DatashiftJourney
  module Models

    # This stores a single Field in a Form, where a field is generally a form
    # element that collects some kind of data
    #
    class FormField < ActiveRecord::Base

      self.table_name = 'dsj_form_fields'

      belongs_to :form

      scope :for_form_and_field,   ->(form_name, field_name) {
        form = Form.where("form = ?", form_name).first
        form.form_fields.where("field = ?", field_name).first
      }

    end
  end
end

