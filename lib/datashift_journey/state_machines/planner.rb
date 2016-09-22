module DatashiftJourney

  module StateMachines

    module Planner

      attr_reader :split_on_state

      attr_accessor :last_processed_state, :last_processed_states

      def split_sequence_map
        @split_sequence_map ||= Planner::hash_klass.new
      end

      def sequence(*list)
        raise PlannerApiError, "Empty list passed to sequence - check your MachineBuilder syntax" if(list.empty?)

        flattened = list.flatten
        # Sequence can be used after a split i.e start a new common sequence,
        # so build links from start of this new sequence, to and from the end points of previous split
        sequence_start = flattened.first

        split_sequence_map.each do |state, sequence_states|

          # sequence_states is whole sequence of the branch for state - we want the end point only
          end_point = sequence_states.last.blank? ? state.to_sym :  sequence_states.last

          create_next(end_point, sequence_start)

          # TODO - Back will require a transition hook to determine which splt to return to
          # create_pair(sequence_start, end_point)

        end if(split_sequence_map)

        # create a next link from Last state to First of this sequence
        create_next(@last_processed_state,  flattened.last) if(@last_processed_state)


        # Now the normal flows within the sequence
        create_back_transitions flattened
        create_next_transitions flattened

        sequence_reset( flattened )
      end

      # Path splits down different branches, based on values from input e,g radio, text or checkbox

      # target_on_value_map is a hash mapping between the value collected from website and the associated
      # named branch. i.e a value collected on state, causes the path to split down that branch
      #
      #     branch_1: 'value from website to direct to branch_1 state',
      #     branch_2: 'a different value'
      #
      def split_on_equality(state, attr_reader, target_on_value_map, options = {})

        unless(target_on_value_map.is_a? Hash)
          raise "BadDefinition - target_on_value_map must be hash map value => associated branch state"
        end

        @split_on_state = state.to_sym

        puts "\nDEBUG: Create split on equality @ [#{@split_on_state}]"

        if(last_processed_state && last_processed_state != split_on_state)
          # Create a Back link from splitting state to last in journey
          create_back(state, last_processed_state)

          # Create a Next link from last in journey to this splitting state
          create_next(last_processed_state, state)
        end

        # When two splits occur consecutively
        last_processed_states.each do |prev_seq_state|

          puts "DEBUG - Previous split state - create_next(#{prev_seq_state}, #{state})"

          # Create a Next link from last in previous  to this splitting state
          create_next(prev_seq_state, state)
        end if(last_processed_states)

        # Each target state should have a transition BACK to this parent split_on state

        target_on_value_map.keys.each do |seq_id|
          target_state = first_target_state(seq_id)

          puts "DEBUG: Create back link from [#{target_state}] to [#{state}]"
          create_back(target_state, state) if(target_state)
        end

        # Now build the next transitions to occur when Model.attribute reader == value
        # For example the Form collects values from radio buttons, each radio selects for a different journey path
        # The split_values would be the radio button values, and the class will need an attribute reader
        # method, returns the value the user clicked.
        #
        # Example of usual form of if statement in the machine, so the state machine takes care of
        # passing in the current model (e.g journey)
        #     if: ->(j) do j.organisation.type == :individual end
        #
        @last_processed_states = []

        target_on_value_map.each do |seq_id, trigger_value|

          puts "\nDEBUG: Building next transitions for each split sequence #{seq_id}"

          target_state = first_target_state(seq_id)

          puts "DEBUG - Create NEXT EVENT from [#{split_on_state}] to [#{target_state}] WITH BLOCK"
          create_next( split_on_state, target_state ) do
            -> (o) {
              unless o && o.respond_to?(attr_reader)
                raise PlannerBlockError, "Cannot split - No such reader method #{attr_reader} on Class #{o.class}"
              end
              o.send(attr_reader) == trigger_value
            }
          end if(target_state)

          @last_processed_states << last_target_state(seq_id)
        end

        @last_processed_states.uniq!
        @last_processed_states.compact!

        # The split sequences will define the end points for this split
        @last_processed_state = nil
      end


      def split_sequence(sequence_id, *list )
        flattened = list.flatten

        create_back_transitions flattened
        create_next_transitions flattened

        puts "DEBUG: Add split sequence for Seq ID #{sequence_id}"
        split_sequence_map[sequence_id] = flattened
      end

      private

      def first_target_state(seq_id)
       # puts "DEBUG - Get First Target for Seq Id [#{seq_id}]  - [#{split_sequence_map.fetch(seq_id, []).first}]"
        split_sequence_map.fetch(seq_id, []).first
      end

      def last_target_state(seq_id)
       # puts "DEBUG - Get LAst Target for Seq Id [#{seq_id}]  - [#{split_sequence_map.fetch(seq_id, []).last}]"
        split_sequence_map.fetch(seq_id, []).last
      end

      def sequence_reset(list)
        @last_processed_state = list.last

        @last_processed_states = nil
        @split_on_state = nil

        @split_sequence_map = Planner::hash_klass.new
      end

      def self.hash_klass
        ActiveSupport::HashWithIndifferentAccess
      end

    end
  end
end
