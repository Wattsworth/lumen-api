Rails.application.routes.draw do

  resources :nilms, only: [:index, :show, :update]
  resources :dbs, only: [:show, :update]
  resources :db_folders, only: [:show, :update]
  resources :db_streams, only: [:update]

  mount_devise_token_auth_for 'User', at: 'auth'
  resources :users, only: [:index, :create, :destroy]
  resources :user_groups, only: [:index, :create, :destroy]
  resources :permissions, only: [:index, :create, :destroy]
end
