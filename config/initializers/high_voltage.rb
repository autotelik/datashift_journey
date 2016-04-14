=begin
You can remove the directory pages from the URL path and serve up routes from the root of the domain path:

http://www.example.com/about
http://www.example.com/company

Would look for corresponding files:

app/views/pages/about.html.erb
app/views/pages/company.html.erb

This is accomplished by setting the route_drawer to HighVoltage::RouteDrawers::Root
=end

HighVoltage.configure do |config|
  # we manage this in the datashift_state/config/routes file
  # to make sure our error catch all routes come last
  config.routes = false
end
