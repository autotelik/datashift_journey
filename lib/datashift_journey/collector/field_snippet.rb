module DatashiftJourney
  module Collector
    class FieldSnippet < ActiveRecord::Base

      self.table_name = 'dsj_fields_snippets'

      belongs_to :form_field
      belongs_to :snippet

    end
  end
end
