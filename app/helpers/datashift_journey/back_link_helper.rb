module DatashiftJourney
  module BackLinkHelper

    # Helper to create a standard Back link that will jumo back to previous state
    def back_a_state_link(journey_plan = nil, css: nil)
      DatashiftJourney::BackLink.new(request, engine_routes: datashift_journey, journey_plan: journey_plan, css: css).tag
    end
  end
end
