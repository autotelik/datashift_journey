module DatashiftJourney
  class PageStatesController < ActionController::API

    include DatashiftJourney::ErrorRenderer

    before_action :set_user, only: [:show, :update, :destroy]

    # PageState contains details for rendering and storing a Page related to a single State
    #
    def index
      @page_states = Collector::PageState.all

      render json: @page_states, status: :ok
    end

    def create
      @page_state = Collector::PageState.new(page_state_params)

      if @page_state.save
        render json: @page_state, status: :created
      else
        render_error(@page_state, :unprocessable_entity) and return
        #render json: { errors: @page_state.errors }, status: :unprocessable_entity
      end
    end

    def show
      render json: @page_state
    end

    private

    # Only allow a trusted parameter "white list" through.
    def page_state_params
      params.fetch(:page_state, {}).permit(:form_name)
    end

    def set_user
      begin
        @page_state = Collector::PageState.find params[:id]
      rescue ActiveRecord::RecordNotFound
        page_state = Collector::PageState.new
        page_state.errors.add(:id, "Wrong ID provided")
        render_error(page_state, 404) and return
      end
    end

  end
end
