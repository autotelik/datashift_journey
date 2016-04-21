require 'rails_helper'

RSpec.describe DatashiftState::JourneyPlansController, type: :routing do
  describe 'routing' do
    # vital when testing an isolated engine
    routes { DatashiftState::Engine.routes }

    # N.B testing the pure engine routes (not mounted within an app
    # e.g at datashift_state) so the routes are /addresses not
    # /datashift_state/addresses

    let(:path) { 'datashift_state/journey_plans' }

    it 'routes to #index' do
      expect(get: '/journey_plans').to route_to(path + '#index')
    end

    it 'routes to #new' do
      expect(get: '/journey_plans/new').to route_to(path + '#new')
    end

    it 'can route via get to #edit to enable copy and paste of url' do
      expect(get: '/journey_plans/1').to route_to(path + '#edit', id: '1')
    end

    it 'has no route to #destroy' do
      expect(delete: '/journey_plans/1').not_to be_routable
    end

    it 'routes to #edit' do
      expect(get: '/journey_plans/1/edit').to route_to(path + '#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/journey_plans').to route_to(path + '#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/journey_plans/1').to route_to(path + '#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/journey_plans/1').to route_to(path + '#update', id: '1')
    end

    it 'routes to #back_a_step via GET' do
      expect(get: '/journey_plans/step/back/1').to route_to(path + '#back_a_step', id: '1')
    end
  end
end
