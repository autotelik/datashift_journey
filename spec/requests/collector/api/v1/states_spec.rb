require 'rails_helper'

module DatashiftJourney

  describe 'States API' do

    RSpec.configure do |config|
      config.render_views = true
    end

    context "list" do

      it 'sends a list of states of current JourneyPlan model' do

        get '/api/v1/states'

        json = parse(response)

        # test for the 200 status-code
        expect(response).to be_success
        expect(json['data']).to have_key 'states'
      end

    end
  end
end