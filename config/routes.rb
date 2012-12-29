Slim::Application.routes.draw do
  resources :workouts
  devise_for :people
  resources :people do
    resources :workouts
    member do
      get 'dashboard'
      get 'overview'
    end
  end
  resources :bps

  #match 'people/rss/:id' => 'people#rss'

  devise_scope :person do
    get "/logout" => "devise/sessions#destroy"
  end

  resources :posts

  match 'measures/deleteall' => 'measures#deleteall'
  match 'measures/refresh' => 'measures#refresh'
  match 'measures/import' => 'measures#import'
  match 'measures/update_trend' => 'measures#update_trend'

  resources :measures
  match 'person/edit' => 'people#edit', :as => :edit_current_person

  match 'chart' => 'measures#chart'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  root :to => "people#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  #match ':controller(/:action(/:id(.:format)))'
end
