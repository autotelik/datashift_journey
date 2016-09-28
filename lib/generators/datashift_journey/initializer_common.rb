module DatashiftJourney

  module InitializerCommon

    def create_initializer_file(journey_class)
      # The app must inform datashift_journey of the model class, that hosts the journey plan
      # For example, in config/initializers/datashift_journey.rb
      # DatashiftJourney.journey_plan_class = "Checkout"

      create_file 'config/initializers/datashift_journey.rb' do
        "\nDatashiftJourney.journey_plan_class = '#{journey_class}'\n\n"\
        "DatashiftJourney::Configuration.configure do |config|\n"\
        "  config.partial_location = '#{journey_class.pluralize.underscore}'\n"\
        "end\n"
      end
    end

    # The journey is stored in a separate concern (module) so model itself uncluttered
    # This module is auto included in the model

    def journey_concern(journey_class)
      create_file "app/models/concerns/#{concern_file(journey_class)}" do
        model_journey_code(journey_class)
      end
    end

    def journey_decorator(journey_class)
      create_file "app/decorators/#{decorator_file(journey_class)}" do
        model_journey_code(journey_class)
      end

      insert_into_file File.join('config', 'application.rb'), after: "class Application < Rails::Application\n" do
        %{

      config.to_prepare do
        Dir.glob(File.join(Rails.root, "app/decorators", "**/*_decorator*.rb")).each do |c|
          require_dependency(c)
        end
      end

}
      end
    end

    def notify_about_routes
      insert_into_file File.join('config', 'routes.rb'), after: "Rails.application.routes.draw do\n" do
        %(
# This line mounts Datashift Journey's routes at the root of your application.
# If you would like to change where this engine is mounted, simply change the :at option to something different.
#
mount DatashiftJourney::Engine => "/"

root to: "datashift_journey/journey_plans#new"
)
      end

      unless options[:quiet]
        puts '*' * 50
        puts "We added the following line to your application's config/routes.rb file:"
        puts ' '
        puts "      mount DatashiftJourney::Engine => '/'"
      end
    end

    # This code will be placed in a model concern and the module included in the model

    def module_journey_code(journey_class)
      module_definition = <<-APP
module #{journey_class}Journey
  #{model_journey_code(journey_class)}
end
      APP
      module_definition
    end

    def model_journey_code(_journey_class)
      model_definition = <<-APP
DatashiftJourney::Journey::MachineBuilder.create_journey_plan(initial: :set_your_initial_state) do

    # The available API is defined in : datashift_journey/lib/datashift_journey/state_machines/planner.rb

    # A basic example with one set of branches, reconnecting to another common section starting at :review
    #
    # sequence [:ship_address, :bill_address]
    #
    # split_on_equality( :payment,
    #                    "payment_card",                  # Helper method on Checkout - returns card type from Payment
    #                     visa_page: 'visa',              # Map sequence start points to values returned
    #                     mastercard_page: 'mastercard',  # by "payment_card" helper method
    #                     paypal_page: 'paypal'
    #  )
    #
    # split_sequence :visa_page, [:page_1_A, :page_2_A]
    #
    # split_sequence :mastercard_page, [:page_1_B, :page_2_B, :page_3_B]
    #
    # split_sequence :paypal_page, []
    #
    # sequence [:review, :complete ]

end
      APP
      model_definition
    end

    # Module name  = options[:journey_class]Journey

    def model_file(journey_class)
      "#{journey_class.underscore}.rb"
    end

    def concern_file(journey_class)
      "#{journey_class.underscore}_journey.rb"
    end

    def decorator_file(journey_class)
      "#{journey_class.underscore}_decorator.rb"
    end

  end

end
