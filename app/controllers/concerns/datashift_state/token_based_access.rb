module DatashiftState
  module TokenBasedAccess
    extend ActiveSupport::Concern
    # Front end journey_plan urls use the journey_plan's token as the id param
    # (see #to_param in journey_plan_decorator.rb). The token is a base58 string of length
    # DatashiftState::SecureToken::TOKEN_LENGTH.
    # A token is only really valid while the journey_plan is being created; once submitted
    # it should not be possible to reference an journey_plan by token or id from the front end.
    included do
      def set_journey_plan
        token = params[:id] || params[:journey_plan_id]
        if token && token.length < DatashiftState::SecureToken::TOKEN_LENGTH
          fail "Expected an journey_plan token but got an journey_plan id"
        end
        @journey_plan = DatashiftState::JourneyPlan.find_by!(token: token)
        logger.debug("Processing Enrollment: #{@journey_plan.inspect}")
      end
    end
  end
end
