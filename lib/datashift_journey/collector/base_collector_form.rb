module DatashiftJourney
  module Collector
    class BaseCollectorForm < DatashiftJourney::BaseForm

      collection :data_nodes do
        property :field_value
      end

      def self.factory(journey_plan)

        page_state = find_or_create_page_state

        create_missing_collector_field(page_state) if page_state.form_fields.empty?

        form_fields = page_state.form_fields

        puts "FIELDS  #{page_state.form_fields.inspect}  #{page_state.form_fields.empty?}"

        form_fields.collect { |ff| journey_plan.data_nodes.build(form_field: ff ) }
=begin
        <%= journey_plan.form_fields.where(form: journey_plan.forms.where(form_name: 'ShipAddress')).each do |ff| %>
      <legend class="visuallyhidden"><%= ff.snippet ? t(ff.snippet.I18n_key) : "Not found" %></legend>
      <%= f.label ff.field,  ff.snippet ? t(ff.snippet.I18n_key) : "Not found", class: 'form-label' %>
        <%#= f.text_field "#{ff.field}_value", class: 'form-control form-control-char-50' %>
  <% end %>
=end
        new(journey_plan)
      end

      alias_attribute :collector, :journey_plan

      # Convention is a database Collector Form with same name as this view's Form class
      def self.collector_form_name
        name.chomp('Form')
      end

      def self.find_or_create_page_state
        Collector::PageState.where(form_name: collector_form_name).first_or_create
      end

      def self.create_missing_collector_field(page_state)
        puts "CREATE MISSING FIELD FOR #{page_state.inspect}"
        FormField.create(page_state: page_state,
                                    field: collector_form_name.underscore,
                                    field_type: :string
        )
      end

    end
  end
end