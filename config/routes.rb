Rails.application.routes.draw do
  resources :user_groups
  resources :permissions
  mount_devise_token_auth_for 'User', at: 'auth'
  resources :db_decimations
  resources :nilms
  resources :dbs
  resources :db_streams
  resources :db_files
  resources :db_folders
end
