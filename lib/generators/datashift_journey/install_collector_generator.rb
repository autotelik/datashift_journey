module DatashiftJourney

  class InstallCollectorGenerator < Rails::Generators::Base

    desc "This generator copies over DSJ migrations to use the generic Collector data models"

    def install_migrations
      say_status :copying, "migrations"
      `rake railties:install:migrations`
    end
  end

end
