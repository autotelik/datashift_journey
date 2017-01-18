require 'rails_helper'

module DatashiftJourney
  module Collector
    RSpec.describe PageState, type: :model do
      context('Empty') do
        let(:collector) { create(:collector, state: :contact_details) }

        it { is_expected.to have_many(:snippets).dependent(false) }

        it { is_expected.to validate_presence_of(:form_name) }

        it 'is valid when the associated Form name supplied' do
          business_details_form = PageState.new(form_name: 'BusinessDetailsForm')
          expect(business_details_form).to be_valid
        end

      end

      context('Populated') do

        let(:page_state) { create(:collector_page_state, :with_snippets) }

        it 'returns the snippets as a single header paragraph' do
          expect(page_state.snippets.size).to eq 3
          expect(page_state.header).to include  page_state.snippets.first.raw_text
          expect(page_state.header).to include  page_state.snippets.last.raw_text
        end

      end

    end
  end
end
