require 'rails_helper'

RSpec.describe DatashiftState::ReviewsController, type: :routing do
  describe 'routing' do
    let(:dsc) { DatashiftState::Engine.routes.url_helpers }

    # vital when testing an isolated engine
    routes { DatashiftState::Engine.routes }

    it 'routes to any specified state via GET' do
      expect(
        get: '/reviews/individual/1').to route_to('datashift_state/reviews#edit', id: '1', state: 'individual')
    end

    it 'routes to any specified state via path' do
      expect(
        get: dsc.review_state_path('individual', 1)
      ).to route_to(controller: 'datashift_state/reviews', action: 'edit', state: 'individual', id: '1')
    end
  end
end
