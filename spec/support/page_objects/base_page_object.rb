require 'capybara/dsl'

class BasePageObject

  RSpec.configure do |_config|
    # this suggested form dont seems to work for latest version of Rails/rspec
    # config.include Rails.application.routes.url_helpers
    # but simply using standard module inclusion does the trick
    include Rails.application.routes.url_helpers

    Rails.application.routes.default_url_options = { host: 'www.example.com' }
  end

  include RSpec::Matchers
  include Capybara::DSL

  # In RSpec the Engine routing proxy method may not be available,
  # Use this helper to prefix Engine paths in your specs  :dsj_url_helper.page_state_path
  #
  def dsj_url_helper
    DatashiftJourney::Engine.routes.url_helpers
  end

  # Default - relies on PageObject utilising the 'state' method
  # so we can create correct journey_plan object and jump straight to right page
  def visit_page
    begin
      @journey_plan ||= DatashiftJourney.journey_plan_class.new
    rescue => e
      puts 'WARNING -RSPEC Setup Issue - No create_related_journey_plan - '\
           "did you call 'state :<state>' in your PageObject ?"
      puts 'See PageObjectHelpers for more details'
      raise e
    end

    Rails.logger.debug("RSPEC : VISITING state [#{journey_plan.state}] with #{journey_plan.inspect}")

    visit dsj_url_helper.journey_plan_state_path(journey_plan.state, journey_plan)

    self
  end

  def visit_state(state)
    visit dsj_url_helper.journey_plan_state_path(state, journey_plan)
  end

  def submit
    click_button('Continue')
  end

  def click_back_link
    click_link(I18n.t('back'))
  end

  # Default advance - fill out page and click submit
  # fill_page  - expect derived to define this - this should not call Submit
  #
  def advance_page
    visit_page unless current_path && has_text?(self.class.on_page_text)
    fill_page
    submit
    find_journey_plan
  end

  def dump
    print page.html
  end

  # requires test has :  js: true
  # rubocop:disable Debugger
  def screenshot(timestamp = '%H%M%S%L')
    file = "/tmp/rspec_po_#{Time.zone.now.strftime(timestamp)}.png"
    save_screenshot(file, full: true)
    puts "RSPEC created screenshot of current page #{file}"
  end

end
