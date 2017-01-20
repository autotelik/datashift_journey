Rswag::Api.configure do |c|

  # Specify a root folder where Swagger JSON files are located
  # This is used by the Swagger middleware to serve requests for API descriptions
  # NOTE: We are using rswag-specs to generate Swagger, sp this PATH is duplicated in spec/swagger_helper.rb

  c.swagger_root = File.join(DatashiftJourney::Engine.root, 'spec', 'swagger')

  # Inject a lamda function to alter the returned Swagger prior to serialization
  # The function will have access to the rack env for the current request
  # For example, you could leverage this to dynamically assign the "host" property
  #
  #c.swagger_filter = lambda { |swagger, env| swagger['host'] = env['HTTP_HOST'] }
end
