module DatashiftState

  class ApplicationController < ActionController::Base

    # This form does NOT seem to work - helpers cause missing method in views
    # helper DatashiftState::Engine.helpers
    # helper "datashift_state/user"

    # This form seems to work - helpers now available in views
    # include DatashiftState::ApplicationHelper
    # include DatashiftState::BackLinkHelper

    before_action :set_i18n_locale_from_params

    rescue_from ActionController::InvalidAuthenticityToken, with: :handle_invalid_authenticity_token

    private

    def set_i18n_locale_from_params
      if params[:locale]
        available = I18n.available_locales.map(&:to_s)
        if available.include?(params[:locale])
          I18n.locale = params[:locale]
          logger.debug "locale set to: #{params[:locale]}"
        else
          flash.now[:notice] = "#{params[:locale]} translation not available"
          logger.error flash.now[:notice]
        end
      end
    end

    # http://jacopretorius.net/2014/01/force-page-to-reload-on-browser-back-in-rails.html
    def back_button_cache_buster
      response.headers['Cache-Control'] = 'no-cache, no-store, max-age=0, must-revalidate'
      response.headers['Pragma'] = 'no-cache'
      response.headers['Expires'] = 'Fri, 01 Jan 1990 00:00:00 GMT'
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_journey_plan
      id = params[:id] || params[:journey_plan_id]
      if id && id.length == DatashiftState::SecureToken::TOKEN_LENGTH
        raise 'Expected an id but got a token'
      end
      @journey_plan = DatashiftState::JourneyPlan.find(id)
      logger.debug("Processing Enrollment: #{@journey_plan.inspect}")
    end

    def handle_invalid_authenticity_token(exception)
      Airbrake.notify(exception) if defined? Airbrake
      Rails.logger.error 'DatashiftState::ApplicationController authenticity failed ' \
                         "(browser cookies may have been disabled): #{exception}"

      render 'datashift_state/errors/invalid_authenticity_token'
    end
  end
end
