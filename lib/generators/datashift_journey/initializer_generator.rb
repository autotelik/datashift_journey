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
class Enrollment < ActiveRecord::Base
    DatashiftJourney::Journey::MachineBuilder.build(initial: :set_your_initial_state_here) do

      # The available API is defined in : datashift_journey/lib/datashift_journey/state_machines/planner.rb
    end
end
      APP
      model_definition
    end

    def model_and_migration
      create_file "app/models/#{options[:model].underscore}.rb" do
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
