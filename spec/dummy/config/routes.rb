Rails.application.routes.draw do

# This line mounts Datashift Journey's routes at the root of your application.
# If you would like to change where this engine is mounted, simply change the :at option to something different.
#
mount DatashiftJourney::Engine => "/"

root to: "datashift_journey/journey_plans#new"

  get '/shift_state/journey_plans/:state/:id', :to => 'datashift_journey/journey_plans#update'
  get '/shift_state/journey_plans/:id', :to => 'datashift_journey/journey_plans#update'

  match '(errors)/:status', to: 'datashift_journey/errors#show', via: :all, constraints: { status: /\d{3}/ }

end
