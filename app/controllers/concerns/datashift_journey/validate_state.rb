module DatashiftJourney

  module ValidateState
    extend ActiveSupport::Concern

    # Needs further investigation into which situations require this

    # http://jacopretorius.net/2014/01/force-page-to-reload-on-browser-back-in-rails.html
    def back_button_cache_buster
      response.headers['Cache-Control'] = 'no-cache, no-store, max-age=0, must-revalidate'
      response.headers['Pragma'] = 'no-cache'
      response.headers['Expires'] = 'Fri, 01 Jan 1990 00:00:00 GMT'
    end

    # Currently the following Situations need special processing, carried out here.
    #
    #   * REFRESH - users hits refresh & resubmits a form - check state associated with view
    #
    # It is not expected to redirect or halt processing chain - it is simply to ensure state is manged correctly,
    # for situations outside standard state flow/processing
    #
    def validate_state
      current_index = journey_plan.current_state_index

      view_state = params[:rendered_state]

      view_state_idx = journey_plan.state_index(view_state) # nil for bad states

      logger.debug 'STATE and Param INFO:'
      logger.debug "  Current State   \t[#{journey_plan.state.inspect}] IDX [#{current_index}]"
      logger.debug "  Rendered State  \t[#{view_state}] IDX [#{view_state_idx}]"
      logger.debug "  Redirect to     \t[#{params[:redirect_to]}]"

      if view_state && view_state_idx && (view_state_idx < current_index)
        logger.info("Probable User refresh, resetting state #{view_state} [IDX (#{view_state_idx})]")
        journey_plan.state = view_state
      end

      if view_state.nil? && params[:state] && back_button_param_list.all? { |p| params.key?(p) }

        transitions = journey_plan.transitions_for

        back_event = transitions.find { |t| t.event == :back }

        if back_event && back_event.from == journey_plan.state && back_event.to == params[:state]
          logger.debug("User CLICKED back Button - resetting state to [#{params[:state]}] from #{journey_plan.state}")
          journey_plan.update!(state: params[:state])
        end

      end
    end

    def back_button_param_list
      @back_button_param_list ||= [:state, :id, :action, :controller]
    end

  end
end
