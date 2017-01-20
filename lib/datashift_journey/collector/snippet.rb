module DatashiftJourney
  module Collector

    class Snippet < ActiveRecord::Base

      self.table_name = 'dsj_snippets'

      def self.to_sentance(snippets)
        snippets.collect { |s| s.I18n_key.present? ? I18n.t(s.I18n_key) : s.raw_text }.join(' ')
      end

    end
  end
end
