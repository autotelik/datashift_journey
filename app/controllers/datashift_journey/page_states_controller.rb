module DatashiftJourney
  class PageStatesController < ActionController::API

    def index
      @page_states = Collector::PageState.all

      render json: PageStatePresenter.minimal_hash_for_collection(@page_states)
    end

    def create
      @page_state = Collector::PageState.new(page_state_params)

      if @page_state.save
        render json: @page_state, status: :created
      else
        render json: @page_state.errors, status: :unprocessable_entity
      end
    end

    private

    # Only allow a trusted parameter "white list" through.
    def page_state_params
      params.require(:page_state).permit(:form_name)
    end

  end
end
