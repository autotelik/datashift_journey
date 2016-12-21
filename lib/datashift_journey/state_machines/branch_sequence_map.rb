require 'forwardable'

module DatashiftJourney

  module StateMachines

    # Map a Sequence to its ID, created in form
    #
    #   branch_sequence :other_sequence, [:other_business]
    #
    #       BranchSequenceMap[:branch_sequence] => Sequence([:other_business])
    #
    class BranchSequenceMap < ActiveSupport::HashWithIndifferentAccess

      # Create a new Sequence if ID not yet in Map, otherwise
      # add the state list to the existing Sequence

      def add_or_concat(id, list)
        key?(id) ? self[id].add_states(list) : add_branch(id, Sequence.new(list.flatten, id: id))
      end

      def add_branch(id, sequence)
        # puts "DEBUG: ADDING TO SEQ [#{id}] BRANCH #{sequence.inspect}"
        self[id] = sequence
      end

      # Find the matching branch sequences for a parent Split (first state)
      def branches_for(sequence)
        values.find_all { |branch| (branch.entry_state && branch.entry_state == sequence.split_entry_state) }
      end

    end

  end
end
