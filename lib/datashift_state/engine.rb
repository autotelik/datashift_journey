module DatashiftState

  class Engine < ::Rails::Engine

    isolate_namespace DatashiftState

    # Add a load path for this specific Engine
    config.autoload_paths += Dir["#{config.root}/lib/**/"]

    config.to_prepare do
      Dir.glob(File.join(Engine.root, 'app/decorators', '**/*_decorator*.rb')).each do |c|
        require_dependency(c)
      end
    end

    # Automatically add our migrations into the main apps migrations
    # As the services provided by core grows we may want to stop this
    # and add generators that copy specific migrations over

    initializer :append_migrations, before: :load_config_initializers do |app|
      unless app.root.to_s.match root.to_s
        config.paths['db/migrate'].expanded.each do |expanded_path|
          # puts "Copy Migrations from DSC [#{expanded_path.inspect}]"
          # puts "To #{app.config.paths["db/migrate"].expanded.inspect}"
          Rails.application.config.paths['db/migrate'] << expanded_path
        end

        Rails.application.config.paths.add('db/migrate_user_db')

        Dir.glob(File.join(Engine.root, 'db/migrate_user_db')).each do |expanded_path|
          Rails.application.config.paths['db/migrate_user_db'] << expanded_path
        end
      end
    end

    # May be needed if we have some static assets
    # Initializer to combine this engines static assets with the static assets
    # of the hosting site.
    # initializer "static assets" do |app|
    #  app.middleware.insert_before(::ActionDispatch::Static,
    #                               ::ActionDispatch::Static, "#{root}/public")
    # end

    # we use rspec for testing
    config.generators do |g|
      g.test_framework :rspec, fixture: false
      g.fixture_replacement :factory_girl, dir: 'spec/factories'
      g.assets false
      g.helper false
    end

    # Make Engine Factories available to Apps and other Engines  - Can be useful in DEV for state jumping
    unless Rails.env.production?
      initializer 'datashift_state.factories', after: 'factory_girl.set_factory_paths' do
        require 'factory_girl'

        path = File.expand_path('../../../spec/factories', __FILE__)
        FactoryGirl.definition_file_paths << path
      end
    end

    # Make Shared examples and Support files available to Apps and other Engines

    # TODO: - make this optional - i.e configurable so Apps/Engines can easily pull this in themselves if they wish
    if Rails.env.test? && defined?(RSpec)
      initializer 'datashift_state.shared_examples' do
        RSpec.configure do
          Dir[File.join(File.expand_path('../../../spec/shared_examples', __FILE__), '**/*.rb')].each { |f| require f }
          Dir[File.join(File.expand_path('../../../spec/support', __FILE__), '**/*.rb')].each { |f| require f }
        end
      end

      config.autoload_paths << File.expand_path('../../../spec/support', __FILE__)
    end

  end

  # To avoid a ton of warnings when the state machine is re-defined
  # StateMachines::Machine.ignore_method_conflicts = true

end

begin
  require_relative 'exceptions'
  require_relative 'configuration'
  require_relative 'datashift_state'
  require_relative 'states/form_object_factory.rb'
  require_relative 'state_machines/state_machine_core_ext'
rescue => x
  # TODO: - remove this block once gem stable
  puts x.inspect
end
