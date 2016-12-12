require 'rails/generators/active_record'
require_relative 'initializer_common'


module DatashiftJourney

  class InstallCollectorGenerator < Rails::Generators::Base

    include Rails::Generators::Migration

    source_root File.expand_path("../templates", __FILE__)

    desc 'This generator copies over DSJ migrations to use the generic Collector data models'

    def copy_collector_migration
        migration_template "collector_migration.rb", "db/migrate/datashift_journey_create_collector.rb", migration_version: migration_version
    end


    extend DatashiftJourney::InitializerCommon
    include DatashiftJourney::InitializerCommon

    # Hmm bit odd but to get thor to work appears we need to wrap calls to our common methods
    def install_common
      create_initializer_file(klass)

      notify_about_routes

      journey_plan_host_file(klass)

      model_journey_code(klass)
    end

    private

    def rails5?
      Rails.version.start_with? '5'
    end

    def klass
      'DatashiftJourney::Models::Collector'
    end

    def migration_version
      if rails5?
        "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]"
      end
    end

  end

end
