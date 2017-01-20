require 'rails_helper'

module DatashiftJourney
  describe 'Collector::PageState API' do
    RSpec.configure do |config|
      config.render_views = true
    end

    it 'sends a list of page states' do
      create_list(:collector_page_state, 10)

      get '/api/v1/page_states'

      json = JSON.parse(response.body)

      # test for the 200 status-code
      expect(response).to be_success

      # check to make sure the right amount of messages are returned
      expect(json.length).to eq(10)
    end

    it 'creates a new page state and responds with JSON body containing expected PageState' do
      expect {
        post '/api/v1/page_states', { page_state: { form_name: 'BrandNewPage' } }, {}
      }.to change(Collector::PageState, :count).by(1)

      json = JSON.parse(response.body)

      # test for the 200 status-code
      expect(response).to be_success

      expect(json).to have_key 'form_name'
      expect(json['form_name']).to eq 'BrandNewPage'
    end

    it 'rejects badly defined page state and responds with Unprocesable entity' do
      expect {
        post '/api/v1/page_states', { page_state: {} }, {}
      }.to_not change(Collector::PageState, :count)

      expect(response.status).to eq(422)

      json = JSON.parse(response.body)

      expect(json).to have_key 'errors'
      expect(json['errors']).to have_key 'form_name'
      expect(json['errors']['form_name']).to eq ["can't be blank"]
    end
  end
end
