Rails.application.routes.draw do
  root "briefings#show"

  resources :briefings, only: :show, param: :date

  get "up" => "rails/health#show", as: :rails_health_check
end
