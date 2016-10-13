require'datashift_journey'
require 'thor'

class StateMachine < Thor

  desc "report", "Report on the states and transitions availblke for current DSJ Journey Plan"

  def report

    environment

    journey_plan = DatashiftJourney.journey_plan_class.new

    state_machine = DatashiftJourney.journey_plan_class.state_machine

    puts "\nINITIAL STATE", journey_plan.state.inspect

    puts "\nEVENTS",journey_plan.state_events.inspect

    puts puts "\nSTATE PATHS",journey_plan.state_paths.inspect

    puts  puts "\nSTATES", state_machine.states.map(&:name).inspect

    puts  puts "\nEVENT KEYS", state_machine.events.keys.sort

    puts  puts "\nBACK", state_machine.events[:back].known_states.sort
  end

  no_commands do

    def environment

      if File.exist?(File.expand_path('config/environment.rb'))
        begin
          require File.expand_path('config/environment.rb')
        rescue => e
         puts ("Failed to initialise ActiveRecord : #{e.message}")
            exit -1
          #raise ConnectionError.new("Failed to initialise ActiveRecord : #{e.message}")
        end

      else
        raise PathError.new('No config/environment.rb found - cannot initialise ActiveRecord')
      end
    end

  end
end
