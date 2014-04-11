ChallengeAccepted::Application.routes.draw do
  resources :challenges

  devise_for :users

  devise_scope :user do
    root to: "devise/registrations#new"
    get "/logout" => "devise/sessions#destroy", as: :logout
    get "/login" => "devise/sessions#new", as: :login
    get "/signup" => "devise/registrations#new", as: :signup
    get "/pwreset" => "devise/passwords#new", as: :pwreset
  end

  post '/challenges/confirm', to: 'challenges#confirm'
  post '/challenges/cancel', to: 'challenges#cancel'



end
