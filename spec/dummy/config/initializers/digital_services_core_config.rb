
# For all available parameters (and to add new ones)
# See :
#         lib/datashift_state/configuration.rb
#
#
DatashiftState.setup do |config|
  # Attempt to pick up the Google Tag Manager ID from an environment variable.
  # If the variable is not set, we cannot use Google Analytics.
  config.google_tag_manager_id = ENV["DSC_FRONTEND_GOOGLE_TAGMANAGER_ID"]

  # Tracking using Google Analytics. As noted above, we can only do this if we
  # know the Google Tag Manager ID.  Additionally, whilst we want to do this
  # in production, it is optional elsewhere.
  config.use_google_analytics = false

  unless config.google_tag_manager_id.blank?
    config.use_google_analytics =
      (ENV["DSC_FRONTEND_USE_GOOGLE_ANALYTICS"] == "true") ||
        Rails.env.production?
  end

  # The phone number shown on the certificate and used in e-mails
  # sent by the application.
  config.services_phone = ENV["DSC_SERVICES_PHONE"]

  # AddressFacade Lookup Service

  config.address_facade_server  = ENV['ADDRESS_FACADE_TEST_SERVER']
  config.address_facade_port    =  ENV['ADDRESS_FACADE_TEST_PORT']
  config.address_facade_url     = '/address-service/v1/addresses'

  config.address_facade_client_id =  ENV['ADDRESS_FACADE_CLIENT_ID']
  config.address_facade_key       =  ENV['ADDRESS_FACADE_KEY']

end
