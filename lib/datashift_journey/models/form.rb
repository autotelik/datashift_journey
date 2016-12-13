module DatashiftJourney
  module Models

    # This stores a single Field in a Form, where a field is generally a form
    # element that collects some kind of data
    #
    class Form < ActiveRecord::Base

      self.table_name = 'dsj_forms'

      has_many :form_fields

    end
  end
end
