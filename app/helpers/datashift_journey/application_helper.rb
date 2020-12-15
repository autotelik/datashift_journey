module DatashiftJourney
  module ApplicationHelper

    # This is the main hook to insert a States partial view into the main Form
    def render_if_exists(state, *args)
      lookup_context.prefixes.prepend DatashiftJourney::Configuration.call.partial_location

      render(state, *args) if lookup_context.exists?(state, lookup_context.prefixes, true)
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
