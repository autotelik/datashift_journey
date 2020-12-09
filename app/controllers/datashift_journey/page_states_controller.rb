module DatashiftJourney
  class FormsController < ActionController::API

    include DatashiftJourney::ErrorRenderer

    before_action :set_user, only: [:show, :update, :destroy]

    # PageState contains details for rendering and storing a Page related to a single State
    #
    def index
      @collector_forms = Collector::Form.all

      render json: @collector_forms, status: :ok
    end

    def create
      @collector_form = Collector::Form.new(page_state_params)

      if @collector_form.save
        render json: @collector_form, status: :created
      else
        render_error(@collector_form, :unprocessable_entity) and return
        #render json: { errors: @collector_form.errors }, status: :unprocessable_entity
      end
    end

    def show
      render json: @collector_form
    end

    private

    # Only allow a trusted parameter "white list" through.
    def page_state_params
      params.fetch(:page_state, {}).permit(:form_name)
    end

    def set_user
      begin
        @collector_form = Collector::Form.find params[:id]
      rescue ActiveRecord::RecordNotFound
        collector_form = Collector::Form.new
        collector_form.errors.add(:id, "Wrong ID provided")
        render_error(collector_form, 404) and return
      end
    end

  end
end
