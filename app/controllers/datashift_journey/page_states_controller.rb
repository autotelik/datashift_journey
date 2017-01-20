module DatashiftJourney
  class PageStatesController < ActionController::API

    # PageState contains details for rendering and storing a Page related to a single State
    #
    def index
      @page_states = Collector::PageState.all

      render json: PageStatePresenter.minimal_hash_for_collection(@page_states), status: :ok
    end

    def create
      @page_state = Collector::PageState.new(page_state_params)

      if @page_state.save
        render json: @page_state, status: :created
      else
        render json: { errors: @page_state.errors }, status: :unprocessable_entity
      end
    end

    private

    # Only allow a trusted parameter "white list" through.
    def page_state_params
      params.fetch(:page_state, {}).permit(:form_name)
    end

  end
end
