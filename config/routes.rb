Rails.application.routes.draw do
  root 'welcome#index'
  resource :workout, controller: :workout, only: [:show, :create]
  match ':controller(/:action)', :via => [:get, :post]

end
