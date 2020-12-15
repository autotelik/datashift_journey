require 'rails'
require 'state_machines-activerecord'
require 'reform'
require 'reform/form'

require_relative 'datashift_journey/state_machines/planner'
require_relative 'datashift_journey/state_machines/extensions'
require_relative 'datashift_journey/state_machines/state_machine_core_ext'
require_relative 'datashift_journey/engine'

module DatashiftJourney

  def self.library_path
    File.expand_path("#{File.dirname(__FILE__)}/../lib")
  end

  # Load all the datashift Thor commands and make them available throughout app
  #
  def self.load_commands
    base = File.join(library_path, 'tasks', '**')

    Dir["#{base}/*.thor"].each do |f|
      next unless File.file?(f)
      load(f)
    end
  end

  # Set the main model class that contains the plan and associated state engine
  #
  def self.journey_plan_class=(x)
    raise 'DSJ - journey_plan_class MUST be String or Symbol, not a Class.' if x.is_a?(Class)

    @journey_plan_class = x

    class << self
      define_method :"concern_file" do
        "#{@journey_plan_class.underscore}_journey.rb"
      end
    end

    # This is called from an initializer, we dont want to trigger the machine building till
    # the model class itself is loaded so do NOT do this here
    # @journey_plan_class = x.to_s.constantize if x.is_a?(String) || x.is_a?(Symbol)

    @journey_plan_class
  end

  def self.journey_plan_class
    @journey_plan_class = @journey_plan_class.to_s.constantize if @journey_plan_class.is_a?(String) || @journey_plan_class.is_a?(Symbol)
    @journey_plan_class
  end

  def self.state_names(machine: :state)
    DatashiftJourney.journey_plan_class.state_machine(machine).states.map(&:name)
  end

end
