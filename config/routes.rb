ChallengeAccepted::Application.routes.draw do
  devise_for :users

  root to: "pages#index", as: :home
  
  get '/challenges/', to: 'challenges#my_challenges'
  get '/challenges/confirm', to: 'challenges#confirm'
  get '/challenges/cancel', to: 'challenges#cancel'
  get '/challenges/:id/cancel', to: 'challenges#cancel'
  get '/challenges/:id/complete', to: 'challenges#complete'  
  get '/challenges/:id/fail', to: 'challenges#fail' 
  get '/challenges/:id/pay', to: 'challenges#pay' 
  get '/challenges/:id/accept', to: 'challenges#accept' 

  get '/challenges/my_challenges', to: 'challenges#my_challenges'
  get '/challenges/proposed_challenges', to: 'challenges#proposed_challenges'
  get '/challenges/other_challenges', to: 'challenges#other_challenges'

  devise_scope :user do
    get "/logout" => "devise/sessions#destroy", as: :logout
    get "/login" => "devise/sessions#new", as: :login
    get "/signup" => "devise/registrations#new", as: :signup
    get "/pwreset" => "devise/passwords#new", as: :pwreset
  end


  resources :users
  resources :challenges

end
