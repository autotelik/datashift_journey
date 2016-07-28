module DatashiftJourney

  class Configuration

    # The module(s) under which to find Forms
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

    # Always use a NullForm when no designated Form for a page
    # @param [Boolean<#call>]
    # @return [Boolean<#call>]
    #
    attr_accessor :use_null_form_when_no_form

    #attr_accessor :state_module_name

    # The location of the View partials, for rendering
    #
    # default is empty, for views stored directly in app/views
    #
    attr_accessor :partial_location

    attr_accessor :layout

    def initialize
      @forms_module_name = ""
      @null_form_list = []
      @partial_location  = ''
      @use_null_form_when_no_form = false
      self.layout = 'application'
    end

    # @return [DatashiftJourney::Configuration] current configuration
    def self.call
      @configuration ||= DatashiftJourney::Configuration.new
    end

    def self.reset
      @configuration = DatashiftJourney::Configuration.new
    end

    # @param config [DatashiftJourney::Configuration]
    class << self
      attr_writer :configuration
    end

    # Modify current DatashiftJourney configuration
    # ```
    #   DatashiftJourney::Configuration.configure do |config|
    #     config.html_only = false
    #   end
    # ```
    def self.configure
      yield call
    end
  end
end
