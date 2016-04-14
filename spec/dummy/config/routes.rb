Rails.application.routes.draw do
  get "/pages/*id" => 'high_voltage/pages#show', as: :page, format: false
  match '(errors)/:status', to: 'datashift_state/errors#show', via: :all, constraints: { status: /\d{3}/ }
end
