ChallengeAccepted::Application.routes.draw do
  devise_for :users

  devise_scope :user do
    root to: "devise/sessions#new"
    get "/logout" => "devise/sessions#destroy", as: :logout
    get "/login" => "devise/sessions#new", as: :login
    get "/signup" => "devise/registrations#new", as: :signup
    get "/pwreset" => "devise/passwords#new", as: :pwreset
  end

  resources :users
end
