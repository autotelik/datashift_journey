module DatashiftJourney

  class ViewsGenerator < Rails::Generators::Base

    source_root File.expand_path('templates', __dir__)

    desc 'This generator creates an initializer and concern to setup and manage the journey Model'

    def create_form_per_state
      method_ptr = if DatashiftJourney.journey_plan_class == DatashiftJourney::Collector::Collector
              ->(p) { view_for_collector_definition(p) }
            else
              ->(p) { view_for_journey_plan_definition(p) }
            end

      partial_location = DatashiftJourney::Configuration.call.partial_location

      path = 'app/views'
      path = File.join(path, partial_location) if partial_location.present?

      DatashiftJourney.state_names.each { |state| method_ptr.call(state.to_s, File.join(path, "_#{state}.html.erb")) }
    end

    private

    def view_for_collector_definition(path)
      template 'collector_view.rb', path
    end

    def view_for_journey_plan_definition(path)
      template 'journey_plan_view.rb', path
    end

  end
end
