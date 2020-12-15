#
# Helper class for constructing back links for navigating backward through the journey
#
module DatashiftJourney

  class BackLink

    include ActionView::Helpers::UrlHelper

    attr_reader :css, :current_request, :journey_plan, :engine_routes

    def initialize(request, engine_routes:, journey_plan: nil, css: nil)
      @current_request = request
      @engine_routes = engine_routes
      @journey_plan = journey_plan
      @css = css
    end

    def tag(text = nil, html_opts = {})
      if journey_plan && (current_request.path == journey_plan_reviewing_path)
        content_tag(:br)
      else
        title, url = link_arguments(text)
        link_to title, url, html_opts.merge(class: css || 'journey-plan-back-link')
      end
    end

    private

    def link_arguments(text = nil)
      [text || link_text, link_url]
    end

    def link_text
      I18n.t(journey_plan ? 'global.back' : 'global.back_to_start_link')
    end

    def link_url
      # TODO: Implement automatic reviewable
      # return  journey_plan_reviewing_path if journey_plan.try! :under_review?

      return start_url unless journey_plan

      journey_plan_back_url
    end

    def start_url
      DatashiftJourney::Configuration.call.backto_start_url
    end

    def journey_plan_back_url
      engine_routes.back_a_state_url(journey_plan)
    end

    def journey_plan_reviewing_path
      engine_routes.journey_plan_state_path('reviewing', journey_plan)
    end

  end
end
