module DatashiftJourney

  class InitializerGenerator < Rails::Generators::Base

    class_option :journey_class, type: :string, required: true, banner: 'The ActiveRecord model to use to manage journey'

    desc 'This generator creates an initializer and concern to setup and manage the journey Model'

    def check_class
      unless /[[:upper:]]/ =~ options[:journey_class][0]
        puts 'ERROR - Please provide a valid Ruby class name for journey_class'
        exit(-1)
      end
    end

    # rubocop:disable Lint/HandleExceptions

    def model_and_migration
      options[:journey_class].to_s.constantize
    rescue
      puts "No such class #{options[:journey_class]} found - creating basic model and migration"

      # create with state column for journey state_machine
      model_options = 'state:string --no-fixture --skip'

      begin
        require 'rspec'
        # This will run if present
        model_options += ' --test-framework=rspec' if defined?(RSpec)
      rescue LoadError
      end

      generate 'model', options[:journey_class], model_options
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

      inject_into_class("app/models/#{model_file(options[:journey_class])}", klass, "\n\tinclude EnrollmentJourney\n\n")
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

  end

end
