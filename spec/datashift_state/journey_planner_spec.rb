require 'rails_helper'

module DatashiftState

  RSpec.describe Journey::Plan do

    describe 'DSL' do

      let(:klass) { Checkout }

      it 'extends the decorated class with extension to StateMachine' do
        expect(klass).to respond_to :state_names
      end

      it "can creta e new plan" do
        plan = Journey::Plan.new
        expect(plan).to be_a Journey::Plan
      end

      it 'enables a simple sequential journey to be planned via simple DSL', duff: true do

        DatashiftState.journey_plan_class = klass.name

        machine = Journey::Plan.build(:checkout_state_machine_name, :page1) do
          sequence :page1, :page2, :page3, :page4
        end

        expect(machine).to be_a ::StateMachines::Machine

        checkout = DatashiftState.journey_plan_class.new

        expect(klass.state_names.size).to eq 4
        expect(klass.state_names.sort).to eq [:page1, :page2, :page3, :page4]

        expect(checkout.state_name).to eq :page1
        expect(checkout.state).to eq "page1"
        expect(checkout.page4?).to eq false

        expect(checkout.can_back?).to eq false
        expect(checkout.can_next?).to eq true

      end
    end

  end
end
