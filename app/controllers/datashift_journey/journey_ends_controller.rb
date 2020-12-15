require_dependency 'datashift_journey/application_controller'

module DatashiftJourney

  class JourneyEndsController < ApplicationController

    def show
      journey_plan_class = params[:journey_plan_class] ? params[:journey_plan_class].constantize : DatashiftJourney.journey_plan_class

      token = params[:id] || params[:journey_plan_id]

      @journey_plan = token ? journey_plan_class.find(token) : journey_plan_class.new

      @journey_plan.on_journey_end if @journey_plan.respond_to? :on_journey_end

    end

  end
end
