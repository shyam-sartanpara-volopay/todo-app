Rails.application.routes.draw do
  resources :users do
    resources :todo_lists, only: [:index, :create] # Nested routes for todo_lists under users
  end

  resources :todo_lists, only: [:show, :create, :update, :destroy]
end
