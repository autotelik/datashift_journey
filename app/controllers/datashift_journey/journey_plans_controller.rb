module DatashiftJourney

  class JourneyPlansController < ApplicationController

    include DatashiftJourney::ReviewRenderer

    # TODO - how to decorate model and auto ionsert migration
    # for has_secure_token so users don't need to know about this at all
    #include TokenBasedAccess

    # We want this to run BEFORE other filters to ensure the current
    # journey_plan object has been selected from the DB
    prepend_before_filter :set_journey_plan, only: [:show, :edit, :update, :destroy, :back_a_state]

    def new
      journey_plan = DatashiftJourney.journey_plan_class.new

      logger.debug "Rendering initial state [#{journey_plan.state}]"
      render locals: {
        journey_plan: journey_plan,
        form: form_object(journey_plan)
      }
    end

    def create
      jp_instance = DatashiftJourney.journey_plan_class.new

      form = form_object(jp_instance)

      if form.validate(params) && form.save
        journey_plan = form.model
        logger.info "Saved JourneyPlan : [#{journey_plan.inspect}]"

        journey_plan.next!
        redirect_to(datashift_journey.journey_plan_state_path(journey_plan.state, journey_plan)) && return
      else
        render :new
      end
    end

    def edit
      logger.debug "Editing journey_plan [#{@journey_plan.inspect}]"

      form = form_object(@journey_plan)

      render locals: {
        journey_plan: @journey_plan,
        form: form
      }
    end

    def back_a_state
      respond_to do |format|
        logger.debug("BACK Requested - current [#{@journey_plan.state}] - previous [#{@journey_plan.previous_state_name}]")

        @journey_plan.back

        if @journey_plan.save

          logger.debug("Successfully back a step - state now [#{@journey_plan.state}]")

          format.html do
            redirect_to(datashift_journey.journey_plan_state_path(@journey_plan.state, @journey_plan)) && return
          end

        else
          format.html { render :edit }
        end
      end
    end

    # How to affect the next state and view :
    #
    # 1)  Pass nothing - Controller will call 'next' and render associated view
    #
    # 2)  Pass in params[:state_event] - Updates state directly, next not called
    #
    #     For example in your main form supply something like
    #         <%= form.hidden_field :state_event, value: :register %>
    #
    #     N.B : This is ignored once we are 'reviewing'
    #
    # 3)  Set the variable @@render_state_partial directly
    #     e.g Within AssignMemberDataForView method's such as setup_for_state
    #
    #     This will over ride rendering view associated with @journey_plan.state
    #
    # 4)  Skip next and view altogether - Pass in  params[:redirect_to])
    #     Will pass params to journey_plan.update but then redirects & returns,
    #     before any call to next or view rendering
    #
    # TODO: We may need to review this method and see if it can be broken up but for now turn off rubocop
    #
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/PerceivedComplexity
    #
    def update

      form = form_object(@journey_plan)

      logger.debug("CALLING VALIDATE ON Form #{form.class}")

      result = form.validate(params)
      logger.debug("VALIATION FAILED - Form Errors [#{form.errors.inspect}]") unless result

      if(result && form.save)
        logger.debug("SUCCESS\n\tProcessed Form [#{form.inspect}]\tUpdated #{@journey_plan.reload.inspect}")

        @journey_plan.next!

        redirect_to(datashift_journey.journey_plan_state_path(@journey_plan.state, @journey_plan)) && return
      else
        logger.debug("FAILED - Form Errors [#{form.errors.inspect}]")
        render :edit, locals: {
          journey_plan: @journey_plan,
          form: form
        }
      end
=begin


        if @journey_plan.update(prepared_params)

          logger.debug("UPDATE SUCCESS !!! #{@journey_plan.inspect} - calling after_state_updated hooks")

          begin
            after_state_updated(@journey_plan, prepared_params)
          rescue => ex
            # these call update! so can throw which causes our error page to display rather than error panel
            Airbrake.notify(ex) if defined? Airbrake
            Rails.logger.error "AfterStateUpdated: failed : #{ex}"
          end

          if prepared_params[:redirect_to]
            logger.debug("REDIRECT specified !!! Calling [#{prepared_params[:redirect_to]}]")
            redirect_to(prepared_params[:redirect_to]) && return
          end

          # Move to next state unless received explicit call to fire specific event, OR reviewing
          if state_event

            # So state transitions can depend on data values on Enrollment. so need to call reload to update our
            # in memory variable. Restricting scope to this branch, as reqment currently restricted to state_event calls
            @journey_plan.reload

            begin
              logger.debug("Firing specific state event [#{state_event}]")
              @journey_plan.send(state_event)
              after_transition(@journey_plan) if respond_to?(:after_transition)
            rescue
              logger.error("Unable to Transition state to [#{state_event}] from #{@journey_plan.valid_for.inspect}")
              raise
            end

          elsif !@journey_plan.under_review
            logger.debug("Calling next on state [#{@journey_plan.state.inspect}]")
            @journey_plan.next!
            logger.debug("Now state @  [#{@journey_plan.state.inspect}]")
          elsif @journey_plan.under_review && !@journey_plan.reviewing?
            logger.debug("State's out of sync under review - resetting to reviewing")
            @journey_plan.review!
            logger.debug("Now state @  [#{@journey_plan.state.inspect}]")
          end

          # this ensures we get the state shown in the url
          redirect_to(datashift_journey.journey_plan_state_path(@journey_plan.state, @journey_plan)) && return

        else
          format.html do
            logger.error("UPDATE FAILED! #{@journey_plan.errors.inspect}")

            if @journey_plan.under_review && params['rendered_state']
              logger.debug("Validation failed during update via review - stay on page [#{params['rendered_state']}]")

              setup_view_data_for_state(params['rendered_state'])

              render_state_under_review(params)
            else
              render :edit
            end
          end
        end
      end
=end
    end # UPDATE

    private

    def form_object(journey_plan)
      DatashiftJourney::FormObjectFactory.form_object_for(journey_plan)
    end

  end
end
