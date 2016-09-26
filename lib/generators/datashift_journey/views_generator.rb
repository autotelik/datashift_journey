module DatashiftJourney

  class ViewsGenerator < Rails::Generators::Base

    # class_option :journey_class, type: :string, required: true, banner: 'The ActiveRecord model to use to manage journey'

    desc 'This generator creates an initializer and concern to setup and manage the journey Model'

    def create_form_per_state
      foo = if DatashiftJourney.journey_plan_class == DatashiftJourney::Collector
              ->(s) { view_for_collector_definition(s) }
            else
              ->(s) { view_for_journey_plan_definition(s) }
            end

      path = 'app/views'

      partial_location = DatashiftJourney::Configuration.call.partial_location

      path = File.join(path, partial_location) if partial_location.present?

      DatashiftJourney.journey_plan_class.state_machine.states.map(&:name).each do |state|
        create_file File.join(path, "_#{state}.html.erb") do
          foo.call(state.to_s)
        end
      end
    end

    private

    def view_for_collector_definition(_state)
      collector_form_definition = <<-EOF
<%#= You can access the Reform form object via local : form %>
<%#= You can access the Reform form model object via  : form.model %>
<%#= You have access to main DSJ jopurney object via local : journey_plan %>

<header class="text">
  <h1 class="form-title heading-large" id="groupLabel"><%= t(".header") %></h1>
</header>

<fieldset>
  <legend class="visuallyhidden"><%= t(".legend") %></legend>
  <%= f.label :field_value,  t(".field_value_label"), class: 'form-label' %>
  <%= f.text_field :field_value, class: 'form-control form-control-char-50' %>
</fieldset>
      EOF

      collector_form_definition
    end

    def view_for_journey_plan_definition(_state)
      collector_form_definition = <<-EOF
<%#= You can access the Reform form object via local : form %>
<%#= You can access the Reform form model object via  : form.model %>
<%#= You have access to main DSJ jopurney object via local : journey_plan %>

<header class="text">
  <h1 class="form-title heading-large" id="groupLabel"><%= t(".header") %></h1>
</header>
      EOF

      collector_form_definition
    end

  end
end
