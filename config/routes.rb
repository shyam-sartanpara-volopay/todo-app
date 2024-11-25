Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'
  resources :users
  resources :todo_lists, only: [:show, :index, :create, :update, :destroy] do
    resources :todos, only: [:index, :create, :update, :destroy] do
      member do
        patch :toggle_status
      end
    end
  end
end