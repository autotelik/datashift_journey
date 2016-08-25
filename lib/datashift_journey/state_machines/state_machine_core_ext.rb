require_relative 'planner'

StateMachines::Machine.class_eval do

  include DatashiftJourney::StateMachines::Planner
  extend DatashiftJourney::StateMachines::Planner

  # Create both a next link from lhs to rhs, and a back link from rhs to lhs

  def create_pair(lhs, rhs)
    create_back(lhs, rhs)
    create_next( rhs, lhs)
  end

  def create_back( from, to, &block )

    if(block_given?)
      #puts "DEBUG: Creating BACK transition from #{from} to #{to} with Block"
      transition( from => to, on: :back, if: block.call)
    else
      #puts "DEBUG: Creating BACK transition from #{from} to #{to}"
      transition( from => to, on: :back)
    end

  end

  def create_next(from, to, &block )
    if(block_given?)
      #puts "DEBUG: Creating NEXT transition from #{from} to #{to} with Block "
      transition( from => to, on: :next, if: block.call)
    else
      #puts "DEBUG: Creating NEXT transition from #{from} to #{to}"
      transition( from => to, on: :next)
    end
  end

  # BACK - Create a 'back' event for each step in list
  # Automatically removes first state, as nothing to go back to from that state
  # You can exclude any other steps with the except list
  #
  def create_back_transitions(journey, except = [])
    journey.drop(1).each_with_index do |t, i|
      next if except.include?(t)
      create_back( t, journey[i] )    # n.b previous index is actually i not (i-1) due to the drop
    end
  end

  # NEXT - Create a 'next' event for each step (apart from last) in journey
  # You can exclude  any other steps with the except list
  #
  def create_next_transitions(journey, except = [])
    journey[0...-1].each_with_index do |t, i|
      next if except.include?(t)
      create_next( t, journey[i + 1] )
    end
  end

end
