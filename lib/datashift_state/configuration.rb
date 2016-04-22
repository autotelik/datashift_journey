module DatashiftState

  class Configuration

    # Forms and views generated in a sub modules of Parent module above
    # This usually equates to state/step/page
    attr_accessor :state_module_name

    # The location of the partials for the Reform forms
    attr_accessor :partial_location

    def initialize
      @state_module_name = 'States'
      @partial_location  = "journey_plans/states"
    end

    # @return [DatashiftState::Configuration] current configuration
    def self.call
      @configuration ||= DatashiftState::Configuration.new
    end

    def self.reset
      @configuration = DatashiftState::Configuration.new
    end

    # @param config [DatashiftState::Configuration]
    class << self
      attr_writer :configuration
    end

    # Modify current DatashiftState configuration
    # ```
    #   DatashiftState::Configuration.configure do |config|
    #     config.html_only = false
    #   end
    # ```
    def self.configure
      yield call
    end
  end
end
