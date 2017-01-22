Rails.application.routes.draw do
  resources :db_decimations
  resources :nilms
  resources :dbs
  resources :db_streams
  resources :db_files
  resources :db_folders
end
