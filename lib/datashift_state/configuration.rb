module DatashiftState

  class Configuration

    # The module under which to find Forms
    # Default Form factory will look for a Form class related to a state called
    #
    #   "#{mod}::#{journey_plan.state}Form"
    #
    attr_accessor :forms_module_name

    attr_accessor :state_module_name

    # The location of the partials for the Reform forms
    attr_accessor :partial_location

    attr_accessor :layout

    def initialize
      @forms_module_name = "Datashift::State"
      @state_module_name = 'States'
      @partial_location  = 'journey_plans/states'
      self.layout = 'application'
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
