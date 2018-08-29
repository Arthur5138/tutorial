Rails.application.routes.draw do
  root 'static_pages#home'
  #static pagesのルート
  get '/help', to:'static_pages#help'
  get '/about', to:'static_pages#about'
  get '/contact', to:'static_pages#contact'
  #セッションのルート
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  #ユーザーのルート
  resources :users 
  get '/signup', to: 'users#new'
  resources :account_activations, only: [:edit]

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
