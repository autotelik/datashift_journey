require "rails_helper"

module DatashiftJourney
  RSpec.describe Collector, type: :model do

    let(:collector) { create(:collector) }

    #it { is_expected.to belong_to(:applicant_contact) }
    it { is_expected.to have_many(:collector_data_nodes).dependent(:destroy) }

  end
end
