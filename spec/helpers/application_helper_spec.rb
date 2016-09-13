require 'rails_helper'

RSpec.describe DatashiftJourney::ApplicationHelper do
  describe '#journey_plan_partial_location' do
    it 'returns partial location for a state' do
      state = 'site_address'
      DatashiftJourney::Configuration.call.partial_location = ""
      expect(helper.journey_plan_partial_location(state)).to eq "/#{state}"

      DatashiftJourney::Configuration.call.partial_location = nil
      expect(helper.journey_plan_partial_location(state)).to eq "/#{state}"
    end

    it 'returns partial location, correctly joining paths for a state' do
      state = 'site_address'
      DatashiftJourney::Configuration.call.partial_location = "shared/states"
      expect(helper.journey_plan_partial_location(state)).to eq "shared/states/#{state}"

      DatashiftJourney::Configuration.call.partial_location = "states/"
      expect(helper.journey_plan_partial_location(state)).to eq "states/#{state}"
    end

  end

  describe '#error_link_anchor' do
    it 'still returns basic string from empty string' do
      attribute = ''
      expect(helper.error_link_id(attribute)).to eq 'form_group_'
    end

    it 'returns attribute from plain attribute' do
      attribute = 'full_name'
      expect(helper.error_link_id(attribute)).to eq 'form_group_full_name'
    end

    it 'returns field only from nested attribute' do
      attribute = 'journey_plan.applicant_contact.full_name'
      expect(helper.error_link_id(attribute)).to eq 'form_group_full_name'
    end
  end
end
