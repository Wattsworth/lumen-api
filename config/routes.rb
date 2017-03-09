Rails.application.routes.draw do

  resources :nilms, only: [:index, :create, :update, :destroy] do
    member do
      put 'refresh'
    end
  end
  resources :dbs, only: [:show, :update]
  resources :db_folders, only: [:show, :update]
  resources :db_streams, only: [:update]

  mount_devise_token_auth_for 'User', at: 'auth'
  resources :users, only: [:index, :create, :destroy]
  resources :user_groups, only: [:index, :update, :create, :destroy] do
    member do
      put 'create_member'
      put 'add_member'
      put 'invite_member'
      put 'remove_member'
    end
  end
  resources :permissions, only: [:index, :create, :destroy]
end
