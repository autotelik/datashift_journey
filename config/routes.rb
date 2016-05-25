DatashiftJourney::Engine.routes.draw do

  resources :journey_plans, except: [:destroy, :show]

  # Note on using get rather than patch  :
  # We use these to provide nicer links - to jump between states & fwd/backwards,
  # but if the Visitor has JS disabled, link_to falls back to get even if patch, put etc specified
  get 'journey_plans/state/back/*id', :to => '/datashift_journey/journey_plans#back_a_state', :as => :back_a_state

  patch '/journey_plans/update/:state', :to => 'journey_plans#update', :as => :update_journey_plan

  # These forms enables us to copy and paste url and see the state in the browser url
  get '/journey_plans/:state/:id', :to => 'journey_plans#edit', :as => :journey_plan_state
  get '/journey_plans/:id', :to => 'journey_plans#edit'

  get 'reviews/:state/*id', :to => '/datashift_journey/reviews#edit', :as => :review_state

  # We have Abandonment derived from high voltage to manage static content
  # related to User's abandoning
  get "/abandonments/*id" => 'abandonments#show', as: :abandonment, format: false

  # includes the high voltage static page to display
  get "/abandon_journey_plans/:page/:id", to: 'abandon_journey_plans#show', as: :abandon_journey_plan

  match '(errors)/:status', to: 'errors#show', via: :all, constraints: { status: /\d{3}/ }
end
