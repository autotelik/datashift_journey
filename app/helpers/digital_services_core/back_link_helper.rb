module DatashiftState
  module BackLinkHelper
    # Helper to create a standard Back link.
    # Containing apps are expected to provide their home page in a DSC config initializer
    # for DatashiftState.backto_start_url
    def backto_start_link(journey_plan = nil)
      DatashiftState::BackLink.new(request, datashift_state, journey_plan).tag
    end
  end
end
