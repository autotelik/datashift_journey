module DatashiftState

  class Configuration

    # The module under which to find Forms
    # Form factory will look for a Form class related to a state called
    #
    #   "#{mod}::#{journey_plan.state}Form"
    #
    # @param [String<#call>] module name under which Forms reside
    # @return [String<#call>]
    #
    attr_accessor :forms_module_name

    # When no Form is required for a specific HTML page, you an specify that a NullForm is to be used
    # by adding that state to this list
    #
    # @param [Array<#call>] List of states that require only a NullForm
    # @return [Array<#call>]
    #
    attr_accessor :null_form_list

    attr_accessor :state_module_name

    # The location of the partials for the Reform forms
    attr_accessor :partial_location

    attr_accessor :layout

    def initialize
      @forms_module_name = "Datashift::State"
      @null_form_list = []
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
