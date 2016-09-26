require 'forwardable'
require_relative 'sequence'

module DatashiftJourney

  module StateMachines

    module Planner

      def sequence(*list)
        raise PlannerApiError, 'Empty list passed to sequence - check your MachineBuilder syntax' if list.empty?
        sequence_list << Sequence.new(list.flatten)
      end

      # Path splits down different branches, based on values stored on the main Journey model
      # usually collected from from input e.g. radio, text or checkbox
      #
      # Requires the starting or parent state, and the routing criteria to each target sequence
      #
      #   split_on_equality( :new_or_renew,
      #                      "what_branch?",             # Helper method on the journey Class
      #                      branch_1: 'branch_1',
      #                      branch_2: 'branch_2'
      #   )
      #
      # target_on_value_map is a hash mapping between the value collected from website and the associated named branch.
      #
      #   if value collected on parent state == stored target state, journey is routed down that branch
      #
      def split_on_equality(state, attr_reader, seq_to_target_value_map, _options = {})
        unless seq_to_target_value_map.is_a? Hash
          raise 'BadDefinition - target_on_value_map must be hash map value => associated branch state'
        end

        sequence_list << Sequence.new(state, split: true)

        seq_to_target_value_map.each do |seq_id, trigger_value|
          if split_sequence_map[seq_id]
            split_sequence_map[seq_id].entry_state = state
            split_sequence_map[seq_id].trigger_method = attr_reader
            split_sequence_map[seq_id].trigger_value = trigger_value
          else
            split_sequence_map[seq_id] = Sequence.new(nil,
                                                      entry_state: state,
                                                      trigger_method: attr_reader,
                                                      trigger_value: trigger_value)
          end
        end
      end

      def split_sequence(sequence_id, *list)
        if split_sequence_map[sequence_id]
          split_sequence_map[sequence_id] += list.flatten
        else
          split_sequence_map[sequence_id] = Sequence.new(list.flatten)
        end
        # puts "DEBUG: Added Split Seq for [#{sequence_id}] #{split_sequence_map[sequence_id].inspect}"
      end

      def self.hash_klass
        ActiveSupport::HashWithIndifferentAccess
      end

      protected

      def build_split_sequence_events(sequence, prev_seq, next_seq)
        # Create BACK from this entry state to the exit point of any PREVIOUS sequence
        create_back(sequence.split_entry_state, prev_seq.last) if prev_seq.last

        split_sequence_map.branches_for(sequence).each do |branch|
          # puts "\n\nDEBUG: MATCH - Process Branch - #{branch.inspect}"

          # Back and next for any states within the split sequence itself
          create_pairs branch

          # N.B A split sequence can actually be empty
          #
          # i.e Some branches may jump straight from the split point straight to next common sequence

          # Now work out the start and end points for this split.
          next_state = branch.empty? ? next_seq.first : branch.first

          # back from first seq state (or if empty next sequence) to this decision state
          split_entry_state = sequence.split_entry_state

          # If branch has no states, a VALUE triggered BACK will be created later
          create_back(branch.first, split_entry_state) unless branch.empty?

          build_triggered_next(branch, split_entry_state, next_state)

          # LAST item in branch connects to FIRST item of NEXT sequence (unless empty and already built with trigger)
          create_next(branch.last, next_seq.first) if !branch.empty? && next_seq.first
        end
      end

      def build_journey_plan_events
        # Ordered collection of sequences

        sequence_list.each_with_index do |sequence, i|
          # put "\nDEBUG: *** START BUILDING NAV FOR #{sequence.inspect} (#{i})"

          prev_seq = i.zero? ? EmptySequence.new : sequence_list[i - 1]

          next_seq = sequence_list[i + 1] || EmptySequence.new

          if sequence.split?
            build_split_sequence_events(sequence, prev_seq, next_seq)
          else

            if prev_seq.split?
              build_triggered_back(sequence, prev_seq)
            elsif prev_seq.last
              create_back(sequence.first, prev_seq.last)
            end

            # The simple navigation through states within the sequence
            create_pairs sequence

            create_next(sequence.last, next_seq.first) if next_seq.first
          end
        end
      end

      def build_triggered_back(sequence, prev_seq)
        # Create back from FIRST item of THIS sequence to LAST entry of EACH previous BRANCH
        split_sequence_map.branches_for(prev_seq).each do |branch|
          create_back(sequence.first, branch.last) do
            lambda do |o|
              unless o && o.respond_to?(branch.trigger_method)
                raise PlannerBlockError, "Cannot Go back - No such method #{branch.trigger_method} on Class #{o.class}"
              end
              o.send(branch.trigger_method) == branch.trigger_value
            end
          end
        end
      end

      def build_triggered_next(branch, from, to)
        create_next(from, to) do
          lambda do |o|
            unless o && o.respond_to?(branch.trigger_method)
              raise PlannerBlockError, "Cannot split - No such method #{branch.trigger_method} on Class #{o.class}"
            end
            o.send(branch.trigger_method) == branch.trigger_value
          end
        end if from && from != to # N.B sequences can self terminate i.e no further sequences and end of the journey
      end

      # Ordered collection of sequences
      def sequence_list
        @sequence_list ||= StateList.new
      end

      # Key - sequence ID
      def split_sequence_map
        @split_sequence_map ||= SplitSequenceMap.new
      end

    end
  end
end
