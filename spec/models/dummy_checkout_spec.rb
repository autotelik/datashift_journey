require 'rails_helper'

RSpec.describe Checkout, type: :model do

  describe '#status' do
    it { is_expected.to respond_to(:state) }
  end

  context '#token' do

    before { skip("Awaiting optional inclusion of token based find") }

    it { is_expected.to validate_presence_of(:token).on(:save) }

    it 'creates a token on creation' do
      journey_plan = described_class.new
      expect(journey_plan.token).to be_nil
      journey_plan.save
      expect(journey_plan.token).to_not be_nil
      expect(journey_plan.token.length).to eq 34
    end
  end
end
