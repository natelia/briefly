Rails.application.routes.draw do
  root "briefings#show"

  resources :briefings, only: :show, param: :date
  patch "stories/:id/mark_read", to: "stories#mark_read", as: :mark_read_story
  patch "stories/:id/mark_unread", to: "stories#mark_unread", as: :mark_unread_story
  post "quiz_questions/:id/answer", to: "quiz_questions#answer", as: :answer_quiz_question

  get "up" => "rails/health#show", as: :rails_health_check
end
