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
  config.route_drawer = HighVoltage::RouteDrawers::Root


  # route '/' to a dummy home pages under views/pages
  config.home_page = 'home'
end