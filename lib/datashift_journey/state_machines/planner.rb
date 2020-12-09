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
          if branch_sequence_map[seq_id]
            branch_sequence_map[seq_id].entry_state = state
            branch_sequence_map[seq_id].trigger_method = attr_reader
            branch_sequence_map[seq_id].trigger_value = trigger_value
          else
            seq = Sequence.new(nil, id: seq_id, entry_state: state, trigger_method: attr_reader, trigger_value: trigger_value)
            branch_sequence_map.add_branch(seq_id, seq)
          end
        end
      end

      def branch_sequence(sequence_id, *list)
        branch_sequence_map.add_or_concat(sequence_id, list)
      end

      def self.hash_klass
        ActiveSupport::HashWithIndifferentAccess
      end

      protected

      # Based upon the current sequences, events defined build the Complete Plan,
      # including back and next navigation
      #
      def build_journey_plan
        # The Order of sequences should have been preserved as insertion order
        sequence_list.each_with_index do |sequence, i|
          prev_seq = i.zero? ? EmptySequence.new : sequence_list[i - 1]

          next_seq = sequence_list[i + 1] || EmptySequence.new

          if sequence.split?
            #puts "\nDEBUG: *** BUILDING SPLITTER #{sequence.inspect} (#{i})"
            build_split_sequence_events(sequence, prev_seq, next_seq)
          else

            # If previous seq is a branch we need to build conditional back transitions, to the end state
            # of each branch (based on the same criteria that originally split the branch)
            if prev_seq.split?
              begin
                #puts "\nDEBUG: *** BUILDING SEQ TO SPLIT #{sequence.inspect} (#{i})"
                build_triggered_back(sequence, prev_seq)
              rescue => x
                puts x.inspect
                puts "Failed in Seq [#{sequence.inspect}] (#{i}) - to create back events to Previous Seq #{prev_seq}"
                raise x
              end

            elsif prev_seq.last
              #puts "\nDEBUG: *** BUILDING SEQ #{sequence.inspect} (#{i})"
              create_back(sequence.first, prev_seq.last)
            end

            # The simple navigation through states within the sequence
            create_pairs sequence

            create_next(sequence.last, next_seq.first) if next_seq.first
          end
        end
      end

      def build_split_sequence_events(sequence, prev_seq, next_seq)
        # puts "\n\nDEBUG: PROCESS SPLIT SEQ #{sequence.inspect}"
        # puts "DEBUG: SPLIT prev_seq #{prev_seq.inspect}"
        # puts "DEBUG: SPLIT next_seq #{next_seq.inspect}"

        # Create BACK from this entry state to the exit point of any PREVIOUS sequence
        create_back(sequence.split_entry_state, prev_seq.last) if prev_seq.last

        branch_sequence_map.branches_for(sequence).each do |branch|
          begin
            # puts "\n\nDEBUG: Process Branch - #{branch.inspect}"

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

            # N.B When multiple splits occur one after the other, branch.last can equal next_seq.first

            # Not sure if that's reflective that logic not too clever elsewhere but for now
            # make sure we don't create such a next event to itself

            # LAST item in branch connects to FIRST item of NEXT sequence (unless empty and already built with trigger)

            if !branch.empty? && next_seq.first && (branch.last != next_seq.first)
              create_next(branch.last, next_seq.first)
            end

          rescue => x
            puts x.inspect
            puts "Failed in Split Sequnce to process Branch #{branch.inspect}"
            raise x
          end
        end
      end

      def build_triggered_back(sequence, prev_seq)
        # puts "DEBUG: * BUILD triggered Back for #{sequence.inspect}"

        # Create back from FIRST item of THIS sequence to LAST entry of EACH previous BRANCH
        branch_sequence_map.branches_for(prev_seq).each do |branch|
          # Branches can be empty - i.e chain direct to next common sequence
          # in which case back goes to the split sequence state itself (parent of branch)
          to_state = branch.last.nil? ? prev_seq.first : branch.last

          create_back(sequence.first, to_state) do
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
        # N.B sequences can self terminate i.e no further sequences and end of the journey
        return unless from && from != to

        create_next(from, to) do
          lambda do |o|
            unless o && o.respond_to?(branch.trigger_method)
              raise PlannerBlockError, "Cannot split - No such method #{branch.trigger_method} on Class #{o.class}"
            end
            o.send(branch.trigger_method) == branch.trigger_value
          end
        end
      end

      # Ordered collection of sequences
      def sequence_list
        @sequence_list ||= StateList.new
      end

      # Key - sequence ID
      def branch_sequence_map
        @split_sequence_map ||= BranchSequenceMap.new
      end

    end
  end
end
