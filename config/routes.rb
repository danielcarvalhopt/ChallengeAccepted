ChallengeAccepted::Application.routes.draw do
  devise_for :users
  
  

  devise_scope :user do
    root to: "devise/registrations#new" # temporario
    get "/logout" => "devise/sessions#destroy", as: :logout
    get "/login" => "devise/sessions#new", as: :login
    get "/signup" => "devise/registrations#new", as: :signup
    get "/pwreset" => "devise/passwords#new", as: :pwreset
  end

  get '/challenges/confirm', to: 'challenges#confirm'
  get '/challenges/cancel', to: 'challenges#cancel'

  resources :users
  resources :challenges

end
