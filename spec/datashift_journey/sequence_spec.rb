require 'rails_helper'

module DatashiftJourney
  module StateMachines

    RSpec.describe Sequence do
      let(:list) { [:review, :complete] }

      describe 'intializing an instance' do
        it 'should create a simple list of states' do
          sequence = Sequence.new(list.flatten)

          expect(sequence).to be_a Sequence
          expect(sequence.states).to eq list
        end
      end
    end

  end
end
