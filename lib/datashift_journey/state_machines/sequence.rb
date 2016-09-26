require 'forwardable'

module DatashiftJourney

  module StateMachines

    class StateList
      extend Forwardable

      def_delegators :@states, :each, :clear, :each_with_index, :[], :<<, :<=>, :<<, :==, :[], :[]=

      def initialize
        @states = []
      end

    end

    class SplitSequenceMap < ActiveSupport::HashWithIndifferentAccess

      # Find the matching branch sequences for a parent Split (first state)
      def branches_for(sequence)
        values.find_all { |branch| (branch.entry_state && branch.entry_state == sequence.split_entry_state) }
      end

    end

    class Sequence
      extend Forwardable

      attr_reader :entry_state, :exit_state

      attr_accessor :split, :trigger_method, :trigger_value

      def_delegators :@states,
                     :clear, :drop, :each, :each_with_index,
                     :empty?, :size,
                     :first, :last,
                     :[], :<<, :<=>, :<<, :==, :[], :[]=, :'+'

      # rubocop:disable Metrics/ParameterLists
      def initialize(states, entry_state: nil, exit_state: nil, trigger_value: nil, trigger_method: nil, split: false)
        @states = [*states]

        @entry_state = entry_state
        @exit_state = exit_state
        @trigger_method = trigger_method
        @trigger_value = trigger_value
        @split = split
      end

      def inspect
        "#{self.class.name} #{@states.inspect} "
      end

      def split?
        split == true
      end

      def branch?
        !trigger_value.nil?
      end

      def split_entry_state
        return nil unless split?
        states.first
      end

      def entry_state=(state)
        @entry_state = state unless entry_state
      end

      def exit_state=(state)
        @exit_state = state unless exit_state
      end

      private

      attr_reader :states
    end

    class EmptySequence < Sequence
      def initialize
        super(nil)
      end
    end

  end
end
