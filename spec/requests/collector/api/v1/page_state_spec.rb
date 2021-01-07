=begin
require 'rails_helper'

module DatashiftJourney

  describe 'Collector::PageState API' do

    RSpec.configure do |config|
      config.render_views = true
    end

    context "API" do

      let(:expected_page_states) { 3 }

      before :each do
        create_list(:collector_page_state, 3)
      end

      it 'sends a list of page states' do

        get '/api/v1/page_states'

        json = parse(response)

        # test for the 200 status-code
        expect(response).to be_success

        # check to make sure the right amount of messages are returned
        expect(json['data'].length).to eq(expected_page_states)
      end

      it 'creates a new page state and responds with JSON body containing expected PageState' do
        expect {
          post '/api/v1/page_states', params: { page_state: { form_name: 'BrandNewPage' } }
        }.to change(Collector::PageState, :count).by(1)

        # test for the 200 status-code
        expect(response).to be_success

        jdata = parse_attribs(response)

        expect(jdata).to have_key 'form-name'
        expect(jdata['form-name']).to eq 'BrandNewPage'
      end

      it 'rejects badly defined page state and responds with Unprocesable entity' do
        expect {
          post '/api/v1/page_states', params: { page_state: {} }
        }.to_not change(Collector::PageState, :count)

        expect(response.status).to eq(422)

        json = parse(response)

        expect(json).to have_key 'errors'

        e = json['errors'][0]
        expect(e).to have_key "source"
        expect(e).to have_key "detail"
        expect(e['detail']).to eq "can't be blank"
      end

      it "should get a valid page state"  do
        page_state = Collector::PageState.first
        get "/api/v1/page_states/#{page_state.id}"
        expect(response).to be_success
        jdata = parse response

        expect( page_state.id.to_s).to eq jdata['data']['id']
        expect( page_state.form_name).to eq  jdata['data']['attributes']['form-name']

        #see Rails.application.routes.default_url_options = {
        expect( page_state_url(page_state, { host: "localhost", port: 3000 }) ).to eq jdata['data']['links']['self']
      end

      it "Should get JSON:API error block when requesting page state data with invalid ID" do
        get '/api/v1/page_states/zzz'
        expect(response.status).to eq(404)
        jdata = parse response
        expect( "Wrong ID provided").to eq  jdata['errors'][0]['detail']
        expect( '/data/attributes/id').to eq  jdata['errors'][0]['source']['pointer']
      end
    end
  end
end

=end
