#
# Helper class for constructing back links for navigating backward through the enrolment journey
#
module DatashiftState
  class BackLink
    include ActionView::Helpers::UrlHelper
    attr_reader :current_request, :journey_plan, :engine_routes

    def initialize(request, engine_routes, journey_plan = nil)
      @current_request = request
      @engine_routes = engine_routes
      @journey_plan = journey_plan
    end

    def tag(text = nil, html_opts = {})
      if journey_plan && (current_request.path == journey_plan_reviewing_path ||
                        journey_plan_is_already_complete?)
        content_tag(:br)
      else
        title, url = link_arguments(text)
        link_to title, url, html_opts.merge(class: "back-link")
      end
    end

    private

    def link_arguments(text = nil)
      [text || link_text, link_url]
    end

    def link_text
      I18n.t(journey_plan_is_mid_registration? ? "back" : "backto_start_link")
    end

    def link_url
      if journey_plan.try! :under_review?
        journey_plan_reviewing_path
      elsif journey_plan_is_mid_registration?
        journey_plan_back_url
      else
        start_url
      end
    end

    def start_url
      if Rails.env.production?
        DatashiftState.backto_start_url
      else
        Rails.application.routes.url_helpers.root_path
      end
    end

    def journey_plan_back_url
      engine_routes.back_a_step_url(journey_plan)
    end

    def journey_plan_reviewing_path
      engine_routes.journey_plan_state_path("reviewing", journey_plan)
    end

    def journey_plan_is_already_complete?
      journey_plan.present? && journey_plan.complete?
    end

    def journey_plan_is_mid_registration?
      journey_plan.present? && !journey_plan.unregistered?
    end
  end
end
