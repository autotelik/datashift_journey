module DatashiftState

  # List here all config parameters we make available via the main Engine
  # i.e Can access via form  : DatashiftState.public_subdomain
  class << self
  end

  # You can yield your own object encapsulating your configuration logic/state
  # Example usage in initializers etc
  #
  #       DatashiftState.setup do |config|
  #         config.public_subdomain = 'localhost'
  #       end
  def self.setup(&block)
    self.set_default_configuration

    yield self
  end

  def self.set_default_configuration
    self.layout = "application"
  end
end
