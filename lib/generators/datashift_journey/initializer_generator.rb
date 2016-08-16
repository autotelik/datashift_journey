module DatashiftJourney

=begin
  The app must inform datashift_journey of the model class, that hosts the journey plan, via an initializer

  For example, in config/initializers/datashift_journey.rb

  DatashiftJourney.journey_plan_class = "Checkout"
=end

  class InitializerGenerator < Rails::Generators::Base

    class_option :model, type: :string, required: true, banner: 'The ActiveRecord model to use to manage journey'

    desc "This generator creates an initializer to setup the Model datashift uses to manage a site journey"

    def create_initializer_file
      create_file "config/initializers/datashift_journey.rb" do
        "\nDatashiftJourney.journey_plan_class = '#{options[:model]}'\n"\
        "DatashiftJourney::Configuration.configure do |config|\n"\
        "  config.partial_location = 'my_checkout_engine'\n"\
        "end\n"
      end
    end

    def model_code
      model_definition=<<-APP
DatashiftJourney::Journey::MachineBuilder.extend_journey_plan_class(initial: :##set_your_initial_state_here) do

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

    def model_and_migration
      create_file "app/models/concerns/#{options[:model].underscore}_journey_plan.rb" do
        model_code
      end

      generate "migration", "Create#{options[:model].classify}", "state:string timestamps"
    end

    def notify_about_routes
      insert_into_file File.join('config', 'routes.rb'), after: "Rails.application.routes.draw do\n" do
        %Q{
  # This line mounts Datashift Journey's routes at the root of your application.
  # If you would like to change where this engine is mounted, simply change the :at option to something different.
  #
  mount DatashiftJourney::Engine => "/"

  root to: "datashift_journey/journey_plans#new"
        }
      end

      unless options[:quiet]
        puts "*" * 50
        puts "We added the following line to your application's config/routes.rb file:"
        puts " "
        puts "      mount DatashiftJourney::Engine => '/'"
      end
    end



  end

end
