module DatashiftJourney
  class SetupGenerator < Rails::Generators::NamedBase

    source_root File.expand_path('templates', __dir__)

    class_option :migration, type: :boolean, default: true, aliases: '-m'

    # This class automatically runs every method defined in it,
    def generate_model
      invoke "active_record:model", [name, 'state:string', 'reference:string:index:unique'], migration: options[:migration] unless model_exists? && behavior == :invoke

      inject_into_file model_path, :after => /class.* < ApplicationRecord/ do
        "\n    include #{class_name}Journey\n\n    validates_presence_of :reference\n\n    validates_uniqueness_of :reference\n"
      end
    end

    def create_files
      template 'initializer.rb', 'config/initializers/datashift_journey.rb'

      # The journey is stored in a separate concern so model file itself uncluttered.
      # This code will be wrapped in a module, which is included in the model
      template 'model_concern.rb', "app/models/concerns/#{class_name.underscore}_journey.rb"
    end

    def add_engine_to_routes

      route("mount DatashiftJourney::Engine => '/journey'")

      puts '*' * 50
      puts "We added the following line to your application's config/routes.rb file:\n"
      puts "  mount DatashiftJourney::Engine => '/journey'"
    end

    private

    def model_exists?
      File.exist?(File.join(destination_root, model_path))
    end

    def model_path
      @model_path ||= File.join(destination_root, "app", "models", "#{file_path}.rb")
    end

  end
end
