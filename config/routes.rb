FancyApp::Application.routes.draw do
  require 'resque/server'
  mount Resque::Server.new, at: "/resque"

  get "main/index"
  root :to => 'main#index'

  scope :format => true, :constraints => { :format => 'json' } do
    resources :posts do
      resources :comments
    end
  end

  match "*foo" => "main#index"

end
