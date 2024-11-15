Rails.application.routes.draw do
  scope defaults: { format: :json } do
  resources :todos, only: [:index, :create, :update, :destroy]
  end
end
