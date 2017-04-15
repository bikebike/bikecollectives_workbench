Rails.application.routes.draw do
  get  '/apps' => 'applications#index', as: :application_index
  get  '/apps/--/new' => 'applications#new', as: :new_application
  get  '/apps/:app/edit' => 'applications#edit', as: :edit_application
  post '/apps/save' => 'applications#save', as: :save_application

  get  '/apps/:app' => 'applications#view', as: :view_application
  get  '/apps/:app/pages/:group' => 'pages#group', as: :page_group
  get  '/apps/:app/pages/:group/:page' => 'pages#page', as: :page
  get  '/apps/:app/pages/:group/:page/:index/:variant' => 'pages#preview', as: :page_preview
  post '/apps/:app/pages/comment/:group/:page/:index/:variant' => 'pages#comment', as: :page_comment

  get  '/apps/:app/translate/:locale' => 'translation#translate_locale', as: :translate_locale
  get  '/apps/:app/translate/:locale/:group/:page' => 'translation#translate_page', as: :translate_page
  post '/apps/:app/translate/:locale/save' => 'translation#save_translation', as: :save_translation
  post '/apps/:app/translate/:locale/watch' => 'translation#watch_translation', as: :watch_translation
  get  '/apps/:app/translate/:locale/:group/:page/:key' => 'translation#translator', as: :translator, constraints: { key: /[^\/]+/ }
  
  get  '/apps/:app/screenshots/:group/:page/:index/:variant.png' => 'example#screenshot', as: :screenshot
  get  '/apps/:app/screenshots/:group/:page/:index/:variant/:hash.png' => 'example#screenshot', as: :cached_screenshot
  get  '/apps/:app/examples/:group/:page/:index' => 'example#page', as: :example_page
  get  '/apps/:app/examples/:group/:page/:index/:hash' => 'example#page', as: :cached_example_page
  get  '/apps/:app/example-files/:dir/:file' => 'example#file', as: :example_file, constraints: { file: /.*/ }

  get  '/users' => 'users#index', as: :users
  get  '/users/:id' => 'users#edit', as: :edit_user
  post '/users/save' => 'users#save', as: :save_user
  post '/users/find' => 'users#find', as: :search_for_user
  post '/access-request' => 'application#access_request', as: :access_request

  get  '/help/:page' => 'application#help', as: :help
  get  '/help' => 'application#help', as: :help_home

  root 'application#home', as: :home
end
