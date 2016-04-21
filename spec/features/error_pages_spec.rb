require 'rails_helper'

module DatashiftState
  describe 'exceptions', type: :feature do
    around :each do |example|
      config = Rails.application.config

      config.consider_all_requests_local = false
      config.action_dispatch.show_exceptions = true

      example.run

      config.consider_all_requests_local = true
      config.action_dispatch.show_exceptions = false
    end

    before :each do
      @routes = Engine.routes
    end

    context '401' do
      scenario 'authentication required but failed or not been provided' do
        visit '/401'
        expect(page.status_code).to eq 401
        expect(page).to have_text I18n.t('global.401_unauthorized.heading')
        expect(page).to have_text I18n.t('global.401_unauthorized.message1')
      end
    end

    # TODO: - Some of these could be improved if we can work out how to stub
    # a real controller action that triggers the required error/exception,
    # for example for 403, visit an unauthorised action

    context '403' do
      scenario 'Forbidden page - authenticating makes no difference' do
        visit '/403'
        expect(page.status_code).to eq 403
        expect(page).to have_text I18n.t('global.403_forbidden.heading')
        expect(page).to have_text I18n.t('global.403_forbidden.message1')
      end
    end

    context '422' do
      scenario 'visitor tries to visit an unprocessable entity ' do
        visit '/422'
        expect(page.status_code).to eq 422
        expect(page).to have_text I18n.t('global.422_unprocessable_entity.heading')
        expect(page).to have_text I18n.t('global.422_unprocessable_entity.message1')
      end
    end

    context '500' do
      scenario 'internal server error' do
        visit '/500'
        expect(page.status_code).to eq 500
        expect(page).to have_text I18n.t('global.500_internal_server_error.heading')
        expect(page).to have_text I18n.t('global.500_internal_server_error.message1')
      end
    end

    context '503' do
      scenario 'valid page but the server is currently unavailable' do
        visit '/503'
        expect(page.status_code).to eq 503
        expect(page).to have_text I18n.t('global.503_bad_gateway.heading')
        expect(page).to have_text I18n.t('global.503_bad_gateway.message1')
      end
    end
  end
end
