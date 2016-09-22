module DatashiftJourney

  class InitializerGenerator < Rails::Generators::Base

    class_option :journey_class, type: :string, required: true, banner: 'The ActiveRecord model to use to manage journey'

    desc "This generator creates an initializer and concern to setup and manage the journey Model"

    def check_class
      unless /[[:upper:]]/.match(options[:journey_class][0])
        puts "ERROR - Please provide a valid Ruby class name for journey_class"
        exit -1
      end
    end

    def model_and_migration

      begin
        options[:journey_class].to_s.constantize
      rescue => e
        puts "No such class #{options[:journey_class]} found - creating basic model and migration"

        # create with state column for journey state_machine
        model_options = "state:string --no-fixture --skip"

        begin
          require 'rspec'
          # This will run if present
          model_options += " --test-framework=rspec" if defined?(RSpec)
        rescue LoadError
        end

        generate "model", options[:journey_class], model_options
      end


    end

    extend DatashiftJourney::InitializerCommon
    include DatashiftJourney::InitializerCommon

    def initializer_file
      create_initializer_file(options[:journey_class])
    end

    # The jounrey is stored in a seperate concern (module) so model itself uncluttered
    # This module is auto included in the model

    def concern
      journey_concern(options[:journey_class])

      klass = options[:journey_class].to_s.constantize

      inject_into_class("app/models/#{model_file}", klass,  "\n\tinclude EnrollmentJourney\n\n")
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


    # This code will be placed in a model concern and the module included in the model
    def model_journey_code
      model_definition=<<-APP
module #{options[:journey_class]}Journey

  DatashiftJourney::Journey::MachineBuilder.extend_journey_plan_class(initial: :set_your_initial_state) do

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
end
      APP
      model_definition
    end

    # Module name  = options[:journey_class]Journey

    def model_file
      "#{options[:journey_class].underscore}.rb"
    end

    def concern_file
      "#{options[:journey_class].underscore}_journey.rb"
    end

  end

end
