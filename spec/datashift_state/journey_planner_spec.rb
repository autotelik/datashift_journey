require 'rails_helper'

# These tests split out testign diff elements into seperate tests so for each
# we need a clean empty class as the State Machines are held at the class level
# and this is easier than trying to manage in one class

class CheckoutEmpty < ActiveRecord::Base;  end
class CheckoutA < ActiveRecord::Base;  end
class CheckoutB < ActiveRecord::Base;  end
class CheckoutB < ActiveRecord::Base; end

module DatashiftState

  RSpec.describe Journey::MachineBuilder do

    describe 'DSL' do

      before(:all) do
        # Only required as we are testing multiple machines using same Class here
        # under normal circumstances build 1 journey per class
        ::StateMachines::Machine.ignore_method_conflicts = true
      end

      let(:klass) { DatashiftState.journey_plan_class }

      context "Simple MachineBuilder" do

        before(:all) do
          DatashiftState.journey_plan_class = "CheckoutEmpty"
        end

        it 'extends the decorated class with extension to StateMachine' do
          pending "rebuilding extensions"
          expect(klass).to respond_to :state_names
        end

        it 'does not break the extended Rails class' do
          expect(klass.new).to be
          expect(klass.create).to be
        end

        it "can build an empty machine with a given name" do
          machine = Journey::MachineBuilder.build(machine_name: :checkout_empty)

          expect(machine).to be_a ::StateMachines::Machine

          expect(machine.name).to eq :checkout_empty
        end
      end

      context "Simple Sequence" do

        before(:all) do
          DatashiftState.journey_plan_class = "CheckoutA"

          @machine = Journey::MachineBuilder.build(machine_name: :checkout_a, initial: :page1) do
            sequence :page1, :page2, :page3, :page4
          end
        end

        it 'enables a sequential journey to be planned via list' do
          expect(@machine).to be_a ::StateMachines::Machine

          expect(@machine).to eq CheckoutA.state_machines[:checkout_a]

          checkout = CheckoutA.new

          # Methods are generated based on the StateMachine name, so where the default is state
          # you get the current column name from 'state_name' so for our tests  becomes checkout_a_name
          expect(checkout.checkout_a_name).to eq :page1
          expect(checkout.checkout_a).to eq "page1"
          expect(checkout.page1?).to eq true
          expect(checkout.page4?).to eq false

          # SO StateMachines::PathCollection seems to map related transitions together, and
          # progressively, so by the last it reports all 6 possible transitions (back/next )
          # not sure based on what yet
          expect( checkout.checkout_a_paths.last.size).to eq 6

          # events is a StateMachines::EventCollection
          # puts CheckoutA.state_machines[:checkout_a].events.each{|e| puts e.inspect }
          expect(CheckoutA.state_machines[:checkout_a].events.keys.sort).to eq [:back, :next]

          #puts CheckoutA.state_machines[:checkout_a].events[:back].known_states.inspect
          expect(
            CheckoutA.state_machines[:checkout_a].events[:back].known_states.sort
          ).to eq [:page1, :page2, :page3, :page4]

        end

        it 'creates back & next transitions for sequential journey' do
          checkout = CheckoutA.new

          # initially can only go fwd
          puts CheckoutA.state_machines[:checkout_a].events.transitions_for(checkout).inspect

          expect( checkout.checkout_a_events.size).to eq 1
          expect( checkout.checkout_a_transitions.size).to eq 1

          expect(checkout.can_back?).to eq false
          expect(checkout.can_next?).to eq true
          checkout.next!

#          puts checkout.methods.sort.grep( /trans/ ).inspect

          # now we should be able to go back and fwd
          expect( checkout.checkout_a_events.size).to eq 2
          expect( checkout.checkout_a_transitions.size).to eq 2

          expect(checkout.can_back?).to eq true
          expect(checkout.can_next?).to eq true
        end
      end

      context "Simple Sequence as Array" do

        before(:all) do
          DatashiftState.journey_plan_class = "CheckoutB"

          @machine = Journey::MachineBuilder.build(machine_name: :checkout_b, initial: :array1) do
            sequence [:array1, :array2, :array3]
          end

        end

        it 'enables a sequential journey to be planned via array' do
          expect(
            CheckoutB.state_machines[:checkout_b].events[:back].known_states.sort
          ).to eq  [:array1, :array2, :array3]

          checkout = klass.new

          expect(checkout.checkout_b_name).to eq :array1
          expect(checkout.checkout_b).to eq "array1"

          expect(checkout.array2?).to eq false

          expect(checkout.can_back?).to eq false
          expect(checkout.can_next?).to eq true
          checkout.next!
          expect(checkout.can_back?).to eq true
          expect(checkout.can_next?).to eq true
          checkout.next!
          expect(checkout.can_back?).to eq true
          expect(checkout.can_next?).to eq false
        end
      end

      context "Complex" do

        let(:klass) {
          DatashiftState.journey_plan_class = "CheckoutC"
          CheckoutC
        }

        it 'enables a complete journey to be planned via simple DSL' do

          machine = Journey::MachineBuilder.build(machine_name: :checkout_c, initial: :bill_address) do

            sequence [:bill_address, :ship_address]

            split_on :payment
=begin
            # split( state, target_states, journey_plan_attr_reader, split_values)
            split :page_split, :split_A do
              [
                :page_1_A,
                :page_2_A
              ]
            end

            split :split_B do
              [
                :page_1_B
              ]
            end

            combine_on :page_come_together
=end
            sequence  [:review, :complete ]

          end

          expect(machine).to be_a ::StateMachines::Machine

          checkout = DatashiftState.journey_plan_class.new

          puts checkout.state_names.inspect

          expect(checkout.state_name(:checkout_complex)).to eq :bill_address

          expect(klass.state_names.size).to eq 5
          expect(klass.state_names.sort).to eq [:page1, :page2, :page3, :page4]
        end

      end

    end
  end
end