begin
  require_relative 'exceptions'
  require_relative 'configuration'
  require_relative 'journey/machine_builder'

  require_relative 'reference_generator'
  require_relative 'helpers/back_link'

rescue => x
  # TODO: - remove this block once gem stable
  puts x.inspect
end

module DatashiftJourney

  class Engine < ::Rails::Engine

    isolate_namespace DatashiftJourney

    # Add a load path for this specific Engine
    config.autoload_paths += Dir["#{config.root}/lib"]

    config.to_prepare do
      # Helpers for dealing with back and next
      # DatashiftJourney.journey_plan_class.send :include, DatashiftJourney::StateMachines::Extensions
      # DatashiftJourney.journey_plan_class.send :extend, DatashiftJourney::StateMachines::Extensions
    end

    # Make Shared examples and Support files available to Apps and other Engines
    # TODO: - make this optional - i.e installable so Apps/Engines can easily pull this in themselves if they wish
    # if Rails.env.test? && defined?(RSpec)
    #   initializer 'datashift_journey.shared_examples' do
    #     RSpec.configure do
    #       Dir[File.join(File.expand_path('../../../spec/shared_examples', __FILE__), '**/*.rb')].each { |f| require f }
    #       Dir[File.join(File.expand_path('../../../spec/support', __FILE__), '**/*.rb')].each { |f| require f }
    #     end
    #   end
    #
    #   config.autoload_paths << File.expand_path('../../../spec/support', __FILE__)
    # end

  end

end
