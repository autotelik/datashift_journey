
module DatashiftJourney
  class PageStatesController < ApplicationController

    def index
      @page_states = DatashiftJourney::Collector::PageState.all

      # Render of the output is automatic via the Views
      # To see JSON format : app/views/datashift_journey/collector/page_states/index.json.jbuilder
    end

  end
end
