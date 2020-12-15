module DatashiftJourney
  class SetupGenerator < Rails::Generators::NamedBase

    source_root File.expand_path('templates', __dir__)

    class_option :migration, type: :boolean, default: true, aliases: '-m'

    # This class automatically runs every method defined in it,
    def generate_model
      Rails::Generators.invoke "active_record:model", [name, 'state:string', 'reference:string:index:unique'], migration: options[:migration] unless model_exists? && behavior == :invoke

      plan = File.open(File.join(SetupGenerator.source_root, "model_concern.rb.tt")).read

      inject_into_file model_path, :after => /class.* < ApplicationRecord/ do
        "\n\tinclude DatashiftJourney::ReferenceGenerator.new(prefix: 'C')\n\tvalidates_presence_of :reference\n\tvalidates_uniqueness_of :reference\n\n#{plan}"
      end
    end

    def create_files
      template 'initializer.rb', 'config/initializers/datashift_journey.rb'
    end

    def add_engine_to_routes
      return if File.readlines(File.join(destination_root, "config/routes.rb")).grep(/mount DatashiftJourney::Engine =>/).present?

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
