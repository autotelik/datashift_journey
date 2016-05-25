module DatashiftJourney

  module ReviewRenderer

    extend ActiveSupport::Concern

    def render_state_under_review(params)
      # We need to track the state we are reviewing across calls.
      # From first edit via the review page itself, this may come as :state
      #
      @rendered_state = params[:rendered_state] || params[:state]

      # Once in review mode, we don't mess with the current state
      # so use the over ride member @render_state_partial to drive which view to render
      @render_state_partial = view_context.journey_plan_partial_location(@rendered_state)

      render template: '/datashift_journey/journey_plans/edit'
    end

  end
end
