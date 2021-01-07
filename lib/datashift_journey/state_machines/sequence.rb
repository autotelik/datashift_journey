require 'forwardable'

module DatashiftJourney

  module StateMachines

    class StateList
      extend Forwardable

      def_delegators :@states, :each, :clear, :each_with_index, :size, :slice, :[], :<<, :<=>, :<<, :==, :[], :[]=

      def initialize
        @states = []
      end

    end

    class Sequence
      extend Forwardable

      attr_reader :id

      attr_reader :entry_state, :exit_state, :states

      attr_accessor :split, :trigger_method, :trigger_value

      def_delegators :@states,
                     :clear, :drop, :each, :each_with_index,
                     :empty?, :size,
                     :first, :last,
                     :[], :<<, :<=>, :<<, :==, :[], :[]=

      # rubocop:disable Metrics/ParameterLists
      def initialize(states, id: '', entry_state: nil, exit_state: nil, trigger_value: nil, trigger_method: nil, split: false)
        @states = [*states]

        @id = id
        @entry_state = entry_state
        @exit_state = exit_state
        @trigger_method = trigger_method
        @trigger_value = trigger_value
        @split = split
      end

      def add_states(list)
        @states.concat(list.flatten)
      end

      def inspect
        "#{self.class.name}(#{id}) - #{@states.inspect} [splitter = #{split?}]"
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

      attr_writer :states
    end

    class EmptySequence < Sequence
      def initialize
        super(nil)
      end
    end

  end
end
