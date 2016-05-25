module DatashiftJourney
  module TokenBasedAccess
    extend ActiveSupport::Concern
    # Front end journey_plan urls use the journey_plan's token as the id param
    # (see #to_param in journey_plan_decorator.rb).
    # A token is only really valid while the journey_plan is being created; once submitted
    # it should not be possible to reference an journey_plan by token or id from the front end.
    included do
      def set_journey_plan
        token = params[:id] || params[:journey_plan_id]

        # https://github.com/robertomiranda/has_secure_token
        @journey_plan = DatashiftJourney.journey_plan_class.find_by_token!(token)

        logger.debug("Processing Journey: #{@journey_plan.inspect}")
      end
    end
  end
end
