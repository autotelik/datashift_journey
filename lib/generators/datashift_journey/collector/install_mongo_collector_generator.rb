require_relative '../initializer_common'

module DatashiftJourney

  class InstallMongoCollectorGenerator < Rails::Generators::Base

    desc 'This generator copies over DSJ migrations to use the generic Collector data collector'

    def install_migrations
      say_status :copying, 'migrations'
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

    def migration_data
      <<RUBY
      field :form, type: String
      field :field , type: String
      field :value, type: String
RUBY
    end

    private

    def klass
      'DatashiftJourney::MongoCollector::MongoCollector'
    end

  end

end
