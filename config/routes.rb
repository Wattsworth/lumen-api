Rails.application.routes.draw do

  resources :nilms, only: [:index, :show, :create, :update, :destroy] do
    member do
      put 'refresh'
    end
  end

  resources :joule_modules, only: [:show]

  resources :data_views do
    collection do
      get 'home' #retrieve a user's home data view
    end
  end

  resources :db_folders, only: [:show, :update]
  resources :db_streams, only: [:index, :update] do
    member do
      post 'data'
    end
  end
  resources :db_elements, only: [:index] do
    collection do
      get 'data'
    end
  end

  # fix for devise invitable from:
  #http://gabrielhilal.com/2015/11/07/integrating-devise_invitable-into-devise_token_auth/
  mount_devise_token_auth_for 'User', at: 'auth', skip: [:invitations]
  devise_for :users, path: "auth", only: [:invitations],
    controllers: { invitations: 'invitations' }

  resources :users, only: [:index, :create, :destroy]
  resources :user_groups, only: [:index, :update, :create, :destroy] do
    member do
      put 'create_member'
      put 'add_member'
      put 'invite_member'
      put 'remove_member'
    end
  end
  resources :permissions, only: [:index, :create, :destroy] do
    collection do
      put 'create_user'
      put 'invite_user'
    end
  end

  get 'interfaces/:id/authenticate', to: 'interfaces#authenticate'
  get 'interfaces/:id', to: 'interfaces#get'
  get 'interfaces/:id/*path', to: 'interfaces#get'
  post 'interfaces/:id/*path', to: 'interfaces#post'

  get 'index', to: 'home#index'
  root to: 'home#index'


end
