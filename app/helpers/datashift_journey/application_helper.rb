module DatashiftJourney
  module ApplicationHelper

    def render_if_exists(state, *args)
      lookup_context.prefixes.prepend DatashiftJourney::Configuration.call.partial_location

      Rails.logger.debug("DSJ search path(s) [#{lookup_context.prefixes.inspect}]")

      if lookup_context.exists?(state, lookup_context.prefixes, true)
        render(state, *args)
      elsif DatashiftJourney.using_collector?
        Rails.logger.debug("DSJ - Using generic Collector viws, no partial found for state #{state}")
        render('datashift_journey/collector/generic_form', *args)
      end
    end

    # Returns true if '_state' partial exists in configured location (Configuration.partial_location)

    def journey_plan_partial?(state)
      return true if lookup_context.exists?(state, [DatashiftJourney::Configuration.call.partial_location], true)

      Rails.logger.warn("DSJ - No partial found for [#{state}] in path(s) [#{lookup_context.prefixes.inspect}]")

      false
    end

    # helper to return the location of a partial for a particular state
    def journey_plan_partial_location(state)
      Rails.logger.debug("DatashiftJourney RENDER #{DatashiftJourney::Configuration.call.partial_location}/#{state}}")
      File.join(DatashiftJourney::Configuration.call.partial_location.to_s, state)
    end

    def submit_button_text(_form)
      t('global.journey_plan.continue')
    end

    def error_link_id(attribute)
      # with nested attributes can get full path e.g applicant_contact.full_name
      # we only want the last field
      field = attribute.to_s.split(/\./).last
      "form_group_#{field}"
    end

    def all_errors(record)
      record.class.reflect_on_all_associations.each do |a|
        assoc = @journey_plan.send(a.name)
        next unless assoc && assoc.respond_to?(:errors)
        assoc.errors.full_messages.each do |_message|
          "<li><a href='<%= message %>'></a></li>"
        end
      end
    end

    def friendly_date(date)
      formatted_date = date && l(date.to_date, format: :long)
      formatted_date || ''
    end

  end
end
