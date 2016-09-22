module DatashiftJourney

  class JourneyPlansController < ApplicationController

    # Run BEFORE other filters to ensure the current journey_plan has been selected from the DB
    prepend_before_filter :set_journey_plan, only: [:edit, :update, :destroy, :back_a_state]

    # Validate state and state related params - covers certain edge cases such as browser refresh
    before_action :validate_state, only: [:edit, :update]

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

      result = form.validate(params)

      logger.debug("VALIDATION FAILED - Form Errors [#{form.errors.inspect}]") unless result

      if form.redirect?
        redirect_to(form.redirection_url) && return
      end

      if(result && form.save)

        journey_plan = form.journey_plan

        if(journey_plan.class != DatashiftJourney.journey_plan_class)
          raise "ClassError - Your Form's model is not a #{DatashiftJourney.journey_plan_class} - #{journey_plan.inspect}"
        end

        journey_plan.reload

        logger.debug("SUCCESS - Updated #{journey_plan.inspect}")

        # if there is no next event, state_machine dynamic helper can_next? not available
        if(!journey_plan.respond_to?('can_next?') )

          logger.error("JOURNEY Cannot proceed - no next transition - rendering 'journey_end'")

          render :journey_end
        elsif(journey_plan.can_next?)
          journey_plan.next!

          redirect_to(datashift_journey.journey_plan_state_path(journey_plan.state, journey_plan)) && return
        else
          logger.error("JOURNEY Cannot proceed - not able to transition to next event'")

          redirect_to(datashift_journey.journey_plan_state_path(journey_plan.state, journey_plan)) && return
        end

      else
        render :new, locals: {
          journey_plan: form.journey_plan,
          form: form
        }
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

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/PerceivedComplexity
    #
    def update

      form = form_object(@journey_plan)

      logger.debug("UPDATE - CALLING VALIDATE ON Form #{form.class}")

      result = form.validate(params)

      if form.redirect?
        redirect_to(form.redirection_url) && return
      end

      if(result && form.save)
        journey_plan = form.journey_plan

        if(journey_plan.class != DatashiftJourney.journey_plan_class)
          raise "ClassError - Your Form's model is not a #{DatashiftJourney.journey_plan_class} - #{journey_plan.inspect}"
        end

        journey_plan.reload

        logger.debug("SUCCESS - Updated #{journey_plan.inspect}")

        # if there is no next event, state_machine dynamic helper can_next? not available
        if(!journey_plan.respond_to?('can_next?') )

          logger.error("JOURNEY Cannot proceed - no next transition - rendering 'journey_end'")

          render :journey_end
        elsif(journey_plan.can_next?)
          journey_plan.next!

          redirect_to(datashift_journey.journey_plan_state_path(journey_plan.state, journey_plan)) && return
        else
          logger.error("JOURNEY Cannot proceed - not able to transition to next event'")

          redirect_to(datashift_journey.journey_plan_state_path(journey_plan.state, journey_plan)) && return
        end
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

    # Needs further investigation into which situations require this

    # http://jacopretorius.net/2014/01/force-page-to-reload-on-browser-back-in-rails.html
    def back_button_cache_buster
      response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
      response.headers["Pragma"] = "no-cache"
      response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
    end

    def set_journey_plan
      token = params[:id] || params[:journey_plan_id]

      # https://github.com/robertomiranda/has_secure_token
      # TODO: how to auto insert has_secure_token into the underlying journey plan model
      # and add in migration thats adds the token column
      # @journey_plan = DatashiftJourney.journey_plan_class.find_by_token!(token)

      @journey_plan = DatashiftJourney.journey_plan_class.find(token)

      logger.debug("Processing Journey: #{@journey_plan.inspect}")
    end

    # Currently the following Situations need special processing, carried out here.
    #
    #   * REFRESH - users hits refresh & resubmits a form - check state associated with view
    #
    # It is not expected to redirect or halt processing chain - it is simply to ensure state is manged correctly,
    # for situations outside standard state flow/processing
    #
    def validate_state
      current_index = @journey_plan.current_state_index

      view_state = params[:rendered_state]

      view_state_idx = @journey_plan.state_index(view_state) # nil for bad states

      logger.debug "STATE and Param INFO:"
      logger.debug "  Enrollment State\t\t[#{@journey_plan.state.inspect}] IDX [#{current_index}]"
      logger.debug "  Rendered State  \t\t[#{view_state}] IDX [#{view_state_idx}]"
      logger.debug "  Redirect to     \t\t[#{params[:redirect_to]}]"

      if(view_state && view_state_idx && (view_state_idx < current_index))
        logger.info("Probable User refresh, resetting state #{view_state} [IDX (#{view_state_idx})]")
        @journey_plan.state = view_state
      end

      if(view_state.nil? && params[:state] && back_button_param_list.all? {|p| params.key?(p) })

        transitions = @journey_plan.transitions_for

        back_event = transitions.find { |t| t.event == :back }

        if(back_event && back_event.from == @journey_plan.state && back_event.to == params[:state])
          logger.debug("User CLICKED back Button - resetting state to [#{params[:state]}] from #{@journey_plan.state}")
          @journey_plan.update!(state: params[:state])
        end

      end
    end

    def back_button_param_list
      @back_button_param_list ||= [:state, :id, :action, :controller]
    end

  end
end
