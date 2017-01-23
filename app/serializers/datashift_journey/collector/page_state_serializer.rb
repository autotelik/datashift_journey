module DatashiftJourney
  module Collector
    class PageStateSerializer < ActiveModel::Serializer
      attributes :id, :form_name, :created_at

      link(:self) {page_state_url(object) }
    end
  end
end