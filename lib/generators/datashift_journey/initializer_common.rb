module DatashiftJourney

  module InitializerCommon

    def next_migration_number(dirname)
      next_migration_number = current_migration_number(dirname) + 1
      ActiveRecord::Migration.next_migration_number(next_migration_number)
    end

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

    def journey_plan_host_file(journey_class)

      path = "app/services/datashift_journey"

      create_file File.join(path, "#{journey_class.underscore}_journey.rb") do
        model_journey_code(journey_class)
      end

      service_loader = <<-EOS

    config.to_prepare do
      Dir.glob(File.join(Rails.root, "#{path}", "**/*.rb")).each do |c|
        require_dependency(c)
      end
    end

 EOS
      application service_loader

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
DatashiftJourney::Journey::MachineBuilder.create_journey_plan(initial: :TO_DO_SET_INITIAL_STATE:) do

=begin
    The available API is defined in : datashift_journey/lib/datashift_journey/state_machines/planner.rb

    A basic example with one set of branches, reconnecting to another common section starting at :review
 
    DatashiftJourney::Journey::MachineBuilder.create_journey_plan(initial: :ship_address) do   
      sequence [:ship_address, :bill_address]
  
        # first define the sequences
        split_sequence :visa_sequence, [:visa_page1, :visa_page2]
  
        split_sequence :mastercard_sequence, [:page_mastercard1, :page_mastercard2, :page_mastercard3]
  
        split_sequence :paypal_sequence, []
  
        # now define the parent state and the routing criteria to each sequence
  
        split_on_equality( :payment,
                           "payment_card",    # Helper method on Checkout that returns card type from Payment
                           visa_sequence: 'visa',
                           mastercard_sequence: 'mastercard',
                           paypal_sequence: 'paypal'
        )
  
        # All branches recombine here at review
        sequence [:review, :complete ]
      end
=end

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
