require "spec_helper"

describe "custom error handling for bad requests", type: :request do
  around :each do |example|
    config = Rails.application.config

    config.consider_all_requests_local = false
    config.action_dispatch.show_exceptions = true

    example.run

    config.consider_all_requests_local = true
    config.action_dispatch.show_exceptions = false
  end

  context "default config" do
    after(:each) do
      expect(response).to render_template("layouts/application")
    end

    context '401 - authentication required but failed or not been provided"' do
      before(:each) do
# TestController.any_instance.stub(:an_admin_page).and_return(:not_logged_in)
# get '/a_forbidden_page
        get "/401"
      end

      it "responds to missing page with 401 status" do
        expect(response.status).to eq(401)
      end

      it "responds to forbidden page with our own 401 page" do
        expected = "datashift_state/errors/401"
        expect(response).to render_template(expected)
      end
    end

    context "403 - Forbidden page - authenticating makes no difference" do
      before(:each) do
        get "/403"
      end

      it "responds to missing page with 403 status" do
        expect(response.status).to eq(403)
      end

      it "responds to forbidden page with our own 403 page" do
        expected = "datashift_state/errors/403"
        expect(response).to render_template(expected)
      end
    end

    context "404 - non existent pages" do
      before(:each) do
        get "/404"
      end

      it "responds to missing page with 404 status" do
        expect(response.status).to eq(404)
      end

      it "responds to missing page with our own 404 page" do
        expected = "datashift_state/errors/404"
        expect(response).to render_template(expected)
      end
    end

    context "422 - an unprocessable entity" do
      before(:each) do
        get "/422"
      end

      it "responds to missing page with 422 status" do
        expect(response.status).to eq(422)
      end

      it "responds to missing page with our own 422 page" do
        expected = "datashift_state/errors/422"
        expect(response).to render_template(expected)
      end
    end

    context "500 - internal server error" do
      before(:each) do
        get "/500"
      end

      it "responds to missing page with 500 status" do
        expect(response.status).to eq(500)
      end

      it "responds to missing page with our own 500 page" do
        expected = "datashift_state/errors/500"
        expect(response).to render_template(expected)
      end
    end

    context "503 - the server is currently unavailable" do
      before(:each) do
        get "/503"
      end

      it "responds to missing page with 503 status" do
        expect(response.status).to eq(503)
      end

      it "responds to missing page with our own 503 page" do
        expected = "datashift_state/errors/503"
        expect(response).to render_template(expected)
      end
    end
  end

  context "configured" do
    before(:all) do
      DatashiftState.layout = "alternative"
    end

    after(:each) do
      expect(response).to render_template("layouts/alternative")
    end

    after(:all) do
      DatashiftState.set_default_configuration
    end

    it "responds to 401 - with configured layout" do
      get "/401"
    end

    it "responds to 403 - with configured layout" do
      get "/403"
    end
    it "responds to 404 - with configured layout" do
      get "/404"
    end

    it "responds to 422 - with configured layout" do
      get "/422"
    end

    it "responds to 500 - with configured layout" do
      get "/500"
    end

    it "responds to 503 - with configured layout" do
      get "/503"
    end
  end
end
