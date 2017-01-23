require 'rails_helper'

module DatashiftJourney
  describe 'API' do
    RSpec.configure do |config|
      config.render_views = true
    end

    def parse(response)
      JSON.parse(response.body)
    end

    def parse_attribs(response)
      JSON.parse(response.body)['data']['attributes']
    end

    context "states" do

      it 'sends a list of states of current JourneyPlan model' do

        get '/api/v1/api/state_list'

        json = parse(response)

        # test for the 200 status-code
        expect(response).to be_success
        expect(json['data']).to have_key 'states'
      end

    end
  end
end