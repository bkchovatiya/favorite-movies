# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  post '/favorite/:movie_id', to: 'movies#favorite_toggle', as: :favorite_toggle
  get '/favorites', to: 'movies#favorite_list', as: :favorite_list
  root 'movies#index'
end
