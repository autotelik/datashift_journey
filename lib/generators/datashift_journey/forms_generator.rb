require 'datashift_journey/collector/base_collector_form'

module DatashiftJourney

  class FormsGenerator < Rails::Generators::Base

    attr_accessor :state

    source_root File.expand_path('templates', __dir__)

    class_option :base_class, type: :string, banner: "ClassName", desc: "Class to use as the Base class for generated Forms"
    class_option :"no-collector", type: :boolean, default: false, desc: "Do not generate form to use inbuilt data Collector"

    desc 'This generator creates an initializer and concern to setup and manage the journey Model'

    def create_form_per_state

      method_ptr = if options["no-collector"] == false || DatashiftJourney.journey_plan_class == DatashiftJourney::Collector::Collector
                     ->() { state_forms_for_collector_definition }
                   else
                     ->() { state_form_definition }
                   end

      DatashiftJourney.journey_plan_class.state_machine(:state).states.map(&:name).each do |state|
        @state = state
        method_ptr.call
      end
    end

    private

    def state_forms_for_collector_definition
      @datashift_journey_baseform = "DatashiftJourney::Collector::BaseCollectorForm"
      template 'base_form.rb', "app/forms/base_form.rb"
      template 'collector_form.rb', "app/forms/#{state}_form.rb"
    end

    def state_form_definition
      @datashift_journey_baseform = "DatashiftJourney::BaseForm"
      template 'base_form.rb', "app/forms/base_form.rb"
      template 'journey_plan_form.rb', "app/forms/#{state}_form.rb"
    end

  end
end
