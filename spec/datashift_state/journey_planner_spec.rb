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

          # If I add in This line :
          #     puts CheckoutB.state_machine.states.map(&:name).inspect
          #
          # It causes the next line to then fail - but it passes ok once outs is commented out !
          # NoMethodError:
          #   undefined method `state=' for #<CheckoutB:0x00000005489018>
          #Did you mean?  state?
          # /home/rubyuser/rubystack-2.2.3-3/rvm/gems/ruby-2.3.1/gems/activemodel-4.2.6/lib/active_model/attribute_methods.rb:433:in `method_missing'
          # /home/rubyuser/rubystack-2.2.3-3/rvm/gems/ruby-2.3.1/gems/state_machines-0.4.0/lib/state_machines/machine.rb:1074:in `write'

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

      context "Complete API" do

        before(:all) do
          DatashiftState.journey_plan_class = "Checkout"

          [:visa, :mastercard, :paypal].each { |p| Payment.create( name: p) }
        end

        let(:payment_types) { [:visa, :mastercard, :paypal] }

        def check_state( checkout, expected_state )
          expect(checkout.state_name).to eq expected_state
          expect(checkout.state).to eq expected_state.to_s
          expect(checkout.state? expected_state).to eq true
        end

        def check_state_and_next( checkout, expected_state )
          check_state( checkout, expected_state )

          expect(checkout.can_back?).to eq true
          expect(checkout.can_next?).to eq true

          checkout.next!
        end

        it 'enables a complete journey to be planned via simple DSL', duff: true do

          DatashiftState::Journey::MachineBuilder.build(initial: :ship_address) do

            sequence [:ship_address, :bill_address]

            split_on_equality( :payment,
                               "payment_card",    # Create helper method on Checkout to return card type from Payment
                               [:visa_page, :mastercard_page, :paypal_page],
                               ['visa', 'mastercard', 'paypal'])

            split_sequence :visa_page, [:page_1_A, :page_2_A]

            split_sequence :mastercard_page, [:page_1_B, :page_2_B, :page_3_B]

            split_sequence :paypal_page, []

            sequence [:review, :complete ]
          end

          checkout = DatashiftState.journey_plan_class.new

          #puts checkout.state_names.inspect
          #puts Checkout.state_machine.states.map(&:name).inspect

          expect(checkout.state? :ship_address).to eq true
          expect(checkout.can_back?).to eq false    # this is the initial state
          expect(checkout.can_next?).to eq true
          checkout.next!

          check_state_and_next( checkout, :bill_address )

          check_state( checkout, :payment )
          # But non of the conditions to move on from payment have been met yet so cannot next
          expect(checkout.can_next?).to eq false
          expect(checkout.can_back?).to eq true

          # TODO - should we also create an Event per state ?
          # Implications to how to manage acceptable transitions to that event
          #expect(checkout.payment?).to eq true

          checkout.create_payment!( card: :mastercard)
          puts checkout.inspect

          # now the conditions should have been met - one block should match the value
          expect(checkout.can_next?).to eq true
          checkout.next!

          check_state_and_next( checkout, :mastercard_page )

          checkout.next!
          checkout.next!

          check_state_and_next( checkout, :page_3_B )

          check_state_and_next( checkout, :review )

          check_state( checkout, :complete )
          # End point so no next
          expect(checkout.can_next?).to eq false
          expect(checkout.can_back?).to eq true

          # Now go all way back to split point and try another path
          checkout.back until(checkout.payment?)

          check_state( checkout, :payment )

          checkout.payment.update(card: :paypal)
          puts checkout.inspect,  checkout.payment.inspect

          checkout.next!

          check_state_and_next( checkout, :paypal_page )
          check_state_and_next( checkout, :review )

        end

      end

    end
  end
end