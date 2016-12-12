Rails.application.routes.draw do

  root to: "datashift_journey/journey_plans#new"

  mount DatashiftJourney::Engine => "/datashift_journey"

  get '/shift_state/journey_plans/:state/:id', :to => 'datashift_journey/journey_plans#update'
  get '/shift_state/journey_plans/:id', :to => 'datashift_journey/journey_plans#update'

  root 'datashift_journey/journey_plans#new'

  match '(errors)/:status', to: 'datashift_journey/errors#show', via: :all, constraints: { status: /\d{3}/ }

end
