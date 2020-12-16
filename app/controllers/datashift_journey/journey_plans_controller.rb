require_dependency 'datashift_journey/application_controller'

module DatashiftJourney

  class JourneyPlansController < ApplicationController

    include ValidateState

    # Run BEFORE other filters to ensure the current journey_plan has been selected from the DB
    prepend_before_action :set_journey_plan, only: [:new, :destroy, :back_a_state]

    prepend_before_action :set_reform_object, only: [:create, :edit, :update]

    # Validate state and state related params - covers certain edge cases such as browser refresh
    before_action :validate_state, only: [:edit, :update]

    def new
      # Find and create the form object, backing the current states view
      reform = FormObjectFactory.form_object_for(journey_plan)

      render locals: { journey_plan: journey_plan, form: reform }
    end

    def create
      # TOFIX - Validation from params is now broken
      # NoMethodError (undefined method `each_with_index' for #<ActionController::Parameters:0x000055eacfa2c370>):
      # result = form.validate(params)
      # logger.debug("VALIDATION FAILED - Form Errors [#{form.errors.inspect}]") unless result
      journey_plan = journey_plan_class.new

      form_fields_to_data_nodes

      move_next(journey_plan)
    end

    def back_a_state
      respond_to do |format|
        logger.debug("BACK Requested - current [#{journey_plan.state}] - previous [#{journey_plan.previous_state_name}]")

        journey_plan.back!

        if journey_plan.save

          logger.debug("Successfully back a step - state now [#{journey_plan.state}]")

          format.html do
            redirect_to(datashift_journey.journey_plan_state_path(journey_plan.state, journey_plan)) && return
          end

        else
          format.html { render :edit }
        end
      end
    end

    def edit
      logger.debug "Editing journey_plan [#{journey_plan.inspect}]"
      render locals: { journey_plan: @journey_plan, form: @reform }
    end

    def update

      # result = form.validate(params)
      #
      # redirect_to(form.redirection_url) && return if form.redirect?
      #
      # if result && form.save
      #   logger.debug("SUCCESS - Updated #{journey_plan.inspect}")
      #
      #   move_next(journey_plan)
      # else
      #   logger.debug("FAILED - Form Errors [#{form.errors.inspect}]")
      #
      #   render :edit, locals: { journey_plan: journey_plan, form: form }
      # end

      form_fields_to_data_nodes

      logger.debug("UPDATED Plan [#{journey_plan.inspect}] - Move to Next")
      puts journey_plan.inspect

      move_next(journey_plan) && return
    end # UPDATE

    def form_fields_to_data_nodes
      form_params = params.fetch(@reform.params_key, {})

      data_nodes = form_params["data_nodes"] # =>{"form_field"=>{"0"=>"name", "1"=>"namespace"}, "field_value"=>{"0"=>"dfsdf", "1"=>"ghfghf"}}}

      if data_nodes.present?

        fields = data_nodes["form_field"]
        values = data_nodes["field_value"]

        fields.each do |idx, name|
          ff = Collector::FormField.where(name: name, form_definition: @reform.definition).first
          next unless ff

          # Ensure when user goes back and changes a value we reflect the changed value
          Collector::DataNode.find_or_initialize_by(plan: journey_plan, form_field: ff).tap do |node|
            node.field_value = values[idx]
            node.save
          end

        end
      end
    end

    private

    def move_next(journey_plan)
      journey_plan.reload

      redirect_to(@reform.redirection_url) && return if @reform.redirect?

      if journey_plan.next_state_name.blank?
        logger.error("JOURNEY ENDED - no next transition - rendering 'journey_end'")
        redirect_to(datashift_journey.journey_end_path(journey_plan)) && return
      end

      # if there is no next event, state_machine dynamic helper can_next? not available
      unless journey_plan.respond_to?('can_skip_fwd?') && journey_plan.can_skip_fwd?
        logger.error("JOURNEY Cannot proceed - no next transition - rendering 'journey_end'")
        redirect_to(datashift_journey.journey_end_path(journey_plan)) && return
      end

      journey_plan.skip_fwd!

      logger.info("JOURNEY moved to next state - Current Plan :")
      logger.info(journey_plan)

      redirect_to(datashift_journey.journey_plan_state_path(journey_plan.state, journey_plan)) && return
    end

    def set_journey_plan_class
      @journey_plan_class = params[:journey_plan_class] ? params[:journey_plan_class].constantize : DatashiftJourney.journey_plan_class
    end

    def set_journey_plan
      set_journey_plan_class

      token = params[:id] || params[:journey_plan_id]

      # TOFIX: Rails 6 probably has this inbuilt now and makes this much simpler - see ActiveSupport::MessageEncryptor, KeyGenerator
      #
      # https://github.com/robertomiranda/has_secure_token
      # TODO: how to auto insert has_secure_token into the underlying journey plan model
      # and add in migration thats adds the token column
      # @journey_plan = DatashiftJourney.journey_plan_class.find_by_token!(token)
      @journey_plan = token ? journey_plan_class.find(token) : journey_plan_class.new
    end

    def set_reform_object
      set_journey_plan_class

      token = params[:id] || params[:journey_plan_id]

      journey_plan = token ? journey_plan_class.find(token) : journey_plan_class.new
      @reform = FormObjectFactory.form_object_for(journey_plan)

      @journey_plan = @reform.journey_plan
    end

    attr_reader :journey_plan_class, :journey_plan
  end
end
