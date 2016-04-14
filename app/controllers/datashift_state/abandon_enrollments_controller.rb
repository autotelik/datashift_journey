module DatashiftState
  class AbandonEnrollmentsController < DatashiftState::AbandonmentsController
    # journey_plan object should been selected from the DB
    prepend_before_filter :set_journey_plan, only: [:show]

    def show
      logger.info("User has abandoned #{params}")

      # high voltage expects  id => name of page
      params[:id] = params["page"]
      super
    end
  end
end
