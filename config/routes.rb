DatashiftJourney::Engine.routes.draw do

  resources :journey_plans, only: [:create, :new, :edit, :update]

  # TODO - Devise generates routes based on module selection .. like we are trying to do with optional Collector
  #   https://github.com/plataformatec/devise/blob/88724e10adaf9ffd1d8dbfbaadda2b9d40de756a/lib/devise/rails/routes.rb

  # TO INVESTIGATE - On an error processing a state user is redirected but this goes to
  #   => http://localhost:3000/journey_plans/(:id)  via a get- which is index or show
  # This currently fixes the issue so a refresh leaves user on right page
  get '/journey_plans(.:format)', :to => 'journey_plans#create'
  get '/journey_plans/:id', :to => 'journey_plans#edit'

  # Note on using get rather than patch  :
  # We use these to provide nicer links - to jump between states & fwd/backwards,
  # but if the Visitor has JS disabled, link_to falls back to get even if patch, put etc specified
  get 'journey_plans/state/back/*id', :to => '/datashift_journey/journey_plans#back_a_state', :as => :back_a_state

  # These forms enables us to copy and paste url and see the state in the browser url
  get '/journey_plans/:state/:id', :to => 'journey_plans#edit', :as => :journey_plan_state

  unless(Rails.env.production?)
    # factory is optional - without it will create bare bones journey_class object with state set
    get '/state_jumper/:state/(:factory)', :to => 'state_jumper#build_and_display', :as => :build_and_display
  end

=begin

  patch '/journey_plans/update/:state', :to => 'journey_plans#update', :as => :update_journey_plan

  get '/journey_plans/:id', :to => 'journey_plans#edit'

  get 'reviews/:state/*id', :to => '/datashift_journey/reviews#edit', :as => :review_state

  # We have Abandonment derived from high voltage to manage static content
  # related to User's abandoning
  get "/abandonments/*id" => 'abandonments#show', as: :abandonment, format: false

  # includes the high voltage static page to display
  get "/abandon_journey_plans/:page/:id", to: 'abandon_journey_plans#show', as: :abandon_journey_plan
=end

  match '(errors)/:status', to: 'errors#show', via: :all, constraints: { status: /\d{3}/ }
end
