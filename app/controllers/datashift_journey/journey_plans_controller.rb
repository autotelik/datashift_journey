module DatashiftJourney

  class JourneyPlansController < ApplicationController

    include ValidateState

    # Run BEFORE other filters to ensure the current journey_plan has been selected from the DB
    prepend_before_filter :set_journey_plan, only: [:edit, :update, :destroy, :back_a_state]

    # Validate state and state related params - covers certain edge cases such as browser refresh
    before_action :validate_state, only: [:edit, :update]

    def new
      journey_plan = DatashiftJourney.journey_plan_class.new

      logger.debug "Rendering initial state [#{journey_plan.state}]"

      render locals: { journey_plan: journey_plan, form: form_object(journey_plan) }
    end

    def create
      # new not create so @ first state - otherwise next will go to 3rd state not 2nd
      jp_instance = DatashiftJourney.journey_plan_class.create

      form = form_object(jp_instance)

      result = form.validate(params)

      logger.debug("VALIDATION FAILED - Form Errors [#{form.errors.inspect}]") unless result

      redirect_to(form.redirection_url) && return if form.redirect?

      if result && form.save
        move_next(form)
      else
        render :new, locals: { journey_plan: form.journey_plan, form: form }
      end
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

      render locals: { journey_plan: journey_plan, form: form_object(journey_plan) }
    end

    def update
      form = form_object(journey_plan)

      logger.debug("UPDATE - CALLING VALIDATE ON Form #{form.class}")

      result = form.validate(params)

      redirect_to(form.redirection_url) && return if form.redirect?

      if result && form.save
        logger.debug("SUCCESS - Updated #{journey_plan.inspect}")

        move_next(form)
      else
        logger.debug("FAILED - Form Errors [#{form.errors.inspect}]")

        render :edit, locals: { journey_plan: journey_plan, form: form }
      end
    end # UPDATE

    private

    def  move_next(form)

      logger.debug "In Move Next [#{form.inspect}]"

      form_journey_plan = form.journey_plan

      if form_journey_plan.class != DatashiftJourney.journey_plan_class
        raise "ClassError - Your Form's model is not a #{DatashiftJourney.journey_plan_class} - #{form_journey_plan.inspect}"
      end

      form_journey_plan.reload

      # if there is no next event, state_machine dynamic helper can_next? not available
      if !form_journey_plan.respond_to?('can_next?')

        logger.error("JOURNEY Cannot proceed - no next transition - rendering 'journey_end'")

        render :journey_end && return
      end

      if form_journey_plan.can_next?
        logger.error("JOURNEY Can proceed - transitioning to next event'")

        form_journey_plan.next!
      else
        logger.error("JOURNEY Cannot Continue - not able to transition to next event")
      end

      redirect_to(datashift_journey.journey_plan_state_path(form_journey_plan.state, form_journey_plan)) && return
    end

    def form_object(journey)
      DatashiftJourney::FormObjectFactory.form_object_for(journey)
    end

    def set_journey_plan
      token = params[:id] || params[:journey_plan_id]

      # https://github.com/robertomiranda/has_secure_token
      # TODO: how to auto insert has_secure_token into the underlying journey plan model
      # and add in migration thats adds the token column
      # @journey_plan = DatashiftJourney.journey_plan_class.find_by_token!(token)

      @journey_plan = DatashiftJourney.journey_plan_class.find(token)
    end

    attr_reader :journey_plan
  end
end
