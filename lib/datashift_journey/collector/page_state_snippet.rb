module DatashiftJourney
  module Collector
    class PageStateSnippet < ActiveRecord::Base

      self.table_name = 'dsj_page_states_snippets'

      belongs_to :page_state
      belongs_to :snippet

    end
  end
end
