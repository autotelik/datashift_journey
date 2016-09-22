require_relative 'initializer_common'

module DatashiftJourney

  class InstallCollectorGenerator < Rails::Generators::Base

    desc "This generator copies over DSJ migrations to use the generic Collector data models"

    def install_migrations
      say_status :copying, "migrations"
      `rake railties:install:migrations`
    end

    extend DatashiftJourney::InitializerCommon
    include DatashiftJourney::InitializerCommon

    # Hmm bit odd but to get thor to work appears we need to wrap calls to our common methods
    def install_common
      create_initializer_file(klass)

      notify_about_routes

      journey_decorator(klass)

      model_journey_code(klass)
    end

    private

    def klass
      "DatashiftJourney::Collector"
    end

  end

end
