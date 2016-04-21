module DatashiftState
  module ApplicationHelper

    # helper to return the default location of partials for a particular state
    def journey_plan_partial_location(state)
      "journey_plans/states/#{state}"
    end

    # This helper  adds a form-group DIV around form elements,
    # and takes the actual form fields as a content block.
    #
    # Some coupling with app/views/shared/_errors.html.erb which displays
    # the actual validation errors and links between error display and the
    # associated form-group defined here
    #
    # Example Usage :
    # <%= form_group_and_validation(@journey_plan, :base) do %>
    #   <%= form.radio_button "blah", "new", checked: false, class: "radio" %>
    #   <%= form.radio_button "blah", "renew", checked: false, class: "radio" %>
    # <% end %>
    #
    def form_group_and_validation(model, attribute, &block)
      content = block_given? ? capture(&block) : ''

      options = { id: error_link_id(attribute),
                  role: 'group',
                  'aria-labelledby': 'groupLabel'
      }

      if model && model.errors[attribute].any?

        content = content_tag(:span, model.errors[attribute].first.to_s.html_safe,
                              class: 'error-message') + content

        content_tag(:div, content, options.merge(class: 'form-group error'))

      else
        content_tag(:div, content, options.merge(class: 'form-group'))
      end
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
        assoc.errors.full_messages.each do |_message|
          "<li><a href='<%= message %>'></a></li>"
        end if assoc && assoc.respond_to?(:errors)
      end
    end

    def validation_for(model, attribute)
      if model.errors[attribute].any?
        # Note: Calling raw() forces the characters to be un-escaped
        # and thus HTML elements can be defined here
        raw('<span class="error-text">'\
            "#{model.errors[attribute].first}</span>")
      else
        ''
      end
    end

    def friendly_date(date)
      formatted_date = date && l(date.to_date, format: :long)
      formatted_date || ''
    end

  end
end