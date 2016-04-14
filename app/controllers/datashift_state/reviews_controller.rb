module DatashiftState

  class ReviewsController < ::ApplicationController

    include DatashiftState::ReviewRenderer

    # We want this to run BEFORE other filters to ensure the current
    # journey_plan object has been selected from the DB

    prepend_before_filter :set_journey_plan, only: [:edit]

    def edit
      logger.info("Sent from REVIEW [#{params.inspect}]")

      respond_to do |format|
        format.html do
          setup_view_data_for_state(params["state"])

          render_state_under_review(params)
        end
      end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_journey_plan
      id = params[:id]
      if id && id.length == DatashiftState::SecureToken::TOKEN_LENGTH
        fail "Expected an id but got a token"
      end
      @journey_plan = DatashiftState::JourneyPlan.find(id)
    end

    # Never trust parameters, only allow the white list through.
    def review_params
      params.permit(:id, :state)
    end

  end
end
