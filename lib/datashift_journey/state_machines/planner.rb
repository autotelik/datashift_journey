module DatashiftJourney

  module StateMachines

    module Planner

      attr_accessor :last_processed_state, :processed_by_split_states, :split_state

      def sequence(*list)
        raise PlannerApiError, "Empty list passed to sequence - check your MachineBuilder syntax" if(list.empty?)

        puts "Building plan from sequence #{list}"

        flattened = list.flatten
        # Sequence can be used after a split i.e start a new common sequence,
        # so build links from start of this new sequence, to and from the end points of previous split
        sequence_start = flattened.first

        processed_by_split_states.each do |state, previous|

          # previous is whole sequence of the branch for state - we want the end point only
          end_point = previous.last.blank? ? state.to_sym :  previous.last

          create_next(end_point, sequence_start)

          # TODO - Back will require a transition hook to determine which splt to return to
          # create_pair(sequence_start, end_point)

        end if(processed_by_split_states)

        # create a next link from Last state to First of this sequence
        create_next(@last_processed_state,  flattened.last) if(@last_processed_state)


        # Now the normalk flows within the sequence
        create_back_transitions flattened
        create_next_transitions flattened

        sequence_reset( flattened )
      end

      # Path splits down different branches, based on values from input e,g radio, text or checkbox

      # target_on_value_map is a hash mapping between the value collected from website and associated branch state
      # that causes the path to split down that branch
      #
      #     branch_1: 'value from website to direct to branch_1 state',
      #     branch_2: 'a different value'
      #
      def split_on_equality(state, attr_reader, target_on_value_map)

        unless(target_on_value_map.is_a? Hash)
          raise "BadDefinition - target_on_value_map must be hash map value => associated branch state"
        end

        @split_state = state.to_sym

        if(last_processed_state && last_processed_state != split_state)
          # Create a Back link from splitting state to last in journey
          create_back(state, last_processed_state)

          # Create a Next link from ast in journey to  this splitting state
          create_next(last_processed_state, state)
        end

        # Each target state should have a back to this parent split_on state
        target_on_value_map.keys.each { |t| create_back(t, state) }

        # Now build the next transitions to occur when Model.attribute reader == value
        # For example the Form collects values from radio buttons, each radio selects for a different journey path
        # The split_values would be the radio button values, and the class will need an attribute reader
        # method, returns the value the user clicked.
        #
        # Example of usual form of if statement in the machine, so the state machine takes care of
        # passing in the current model (e.g journey)
        #     if: ->(j) do j.organisation.type == :individual end
        #
        target_on_value_map.each do |target_state, v|

          create_next( split_state, target_state ) do
            -> (o) {
              unless o && o.respond_to?(attr_reader)
                raise PlannerBlockError, "Cannot split - No such reader method #{attr_reader} on Class #{o.class}"
              end
              o.send(attr_reader) == v
            }
          end

        end

        # The split sequences will define the end points for this split
        @last_processed_state = nil
        @processed_by_split_states ||= Planner::hash_klass.new
      end


      def split_sequence(state, *list )
        flattened = list.flatten

        create_next(state, flattened.first)  unless(flattened.empty?)

        create_back_transitions flattened
        create_next_transitions flattened

        @processed_by_split_states[state] = flattened
      end

      private

      def sequence_reset(list)
        @last_processed_state = list.last

        @split_state = nil

        @processed_by_split_states = Planner::hash_klass.new
      end

      def self.hash_klass
        ActiveSupport::HashWithIndifferentAccess
      end

    end
  end
end
