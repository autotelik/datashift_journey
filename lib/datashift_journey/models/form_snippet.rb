module DatashiftJourney
  module Models
    class FormSnippet < ActiveRecord::Base

      self.table_name = 'dsj_forms_snippets'

      belongs_to :form
      belongs_to :snippet

    end
  end
end
