Rails.application.routes.draw do
  root "briefings#show"

  resources :briefings, only: :show, param: :date
  patch "stories/:id/mark_read", to: "stories#mark_read", as: :mark_read_story

  get "up" => "rails/health#show", as: :rails_health_check
end
