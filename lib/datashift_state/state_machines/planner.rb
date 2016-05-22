module DatashiftState

  module StateMachines

    module Planner

      attr_accessor :last_processed_state, :processed_by_split_state

      attr_accessor :split_state

      def sequence(*list)
        puts "IN sequence #{list}"
        flattened = list.flatten
        create_back_transitions flattened
        create_next_transitions flattened

        # create a next link from Last state to First of this sequence
        create_next(@last_processed_state,  flattened.last) if(@last_processed_state)

        @last_processed_state = flattened.last
        @split_state = nil

        # Sequence can also be used to end a split i.e start a new common sequence

        sequence_start = flattened.first

        puts "Processing previous split PATH [#{processed_by_split_state.inspect}]"
        processed_by_split_state.each do |state, previous|

          if(previous.empty?)
            create_pair(sequence_start, state.to_sym)
          else
            create_pair(sequence_start, previous.last)
          end
        end if(processed_by_split_state)

        @processed_by_split_state = Planner::hash_klass.new
      end

      def split_on( state )
        #puts "IN split_on #{state}"
        @split_state = state

        create_pair(state, @last_processed_state)

        @last_processed_state = state
      end

      def split_on_equality(state, attr_reader, target_states, split_values)
        #puts "IN split_on_equality [#{state}] => #{target_states}"

        raise "BadDefinition" unless(target_states.size == split_values.size)

        @split_state = state

        if(last_processed_state)
          # Create a Back link from splitting state to last in journey
          create_back(state, last_processed_state)

          # Create a Next link from ast in journey to  this splitting state
          create_next(last_processed_state, state)
        end

        @last_processed_state = state

        # Each target state has a back to the split_on state
        target_states.each { |t| create_back(t, @last_processed_state) }

        # Now build the next transitions to occur when Model.attribute reader == value
        # For example the Form collects values from radio buttons, each radio selects for a different journey path
        # The split_values would be the radio button values, and the class will need an attribute reader
        # method, returns the value the user clicked.
        #
        # Example of usual form of if statement in the machine, so the state machine takes care of
        # passing in the current model (e.g journey)
        #     if: ->(j) do j.organisation.type == :individual end
        #
        split_values.each_with_index do |v, i|
          at = -> (o) {
            raise "Bad Defintion", "No such method #{attr_reader} on #{o.inspect}" unless o.respond_to?(attr_reader)
            Rails.logger.debug "BLOCK [#{ o.send(attr_reader)}] == [#{v.class}] (#{o.send(attr_reader) == v})";
            puts "BLOCK [#{o.send(attr_reader)}] == [#{v}] (#{o.send(attr_reader) == v})";
            o.send(attr_reader) == v
          }
          create_next( split_state, target_states[i] ) do at end
        end

        # The split sequences will define the end points for this split
        @last_processed_state = nil

        @processed_by_split_state ||= Planner::hash_klass.new
      end


      def split_sequence(state, *list )
        puts "IN split_sequence #{state} -> #{list}"

        flattened = list.flatten

        unless(flattened.empty?)
          create_next(state, flattened.first)
          create_back(flattened.first, state)

          create_back_transitions flattened
          create_next_transitions flattened
        end
        @processed_by_split_state[state] ||= flattened
      end

      private

      def self.hash_klass
        ActiveSupport::HashWithIndifferentAccess
      end

    end
  end
end
