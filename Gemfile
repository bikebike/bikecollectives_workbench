source 'http://rubygems.org'

gem 'rails', '4.2.0'
gem 'pg'
gem 'rake', '11.1.2'
gem 'ruby_dep', '1.3.1' # Lock at 1.3.1 since 1.4 requires ruby 2.5. We should unlock once we upgrade the ruby version on our server

# gem 'rack-mini-profiler'

gem 'haml'
gem 'nokogiri', '~> 1.6.8.rc2'

gem 'tzinfo-data'
gem 'sass'
gem 'sass-rails'
gem 'uglifier', '>= 1.3.0'
gem 'sorcery', '>= 0.8.1'
gem 'oauth2', '~> 0.8.0'
gem 'carrierwave'
gem 'carrierwave-imageoptimizer'
gem 'mini_magick'
gem 'activerecord-session_store'
gem 'premailer-rails'
gem 'sidekiq'
gem 'letter_opener'
gem 'launchy'

if Dir.exists?('../lingua_franca')
  gem 'lingua_franca', path: '../lingua_franca'
else
  gem 'lingua_franca', git: 'https://github.com/lingua-franca/lingua_franca.git'
end

if Dir.exists?('../bikecollectives_core')
  gem 'bikecollectives_core', path: '../bikecollectives_core'
else
  gem 'bikecollectives_core', git: 'https://github.com/bikebike/bikecollectives_core.git'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'meta_request'
  
  gem 'eventmachine', git: 'https://github.com/krzcho/eventmachine', branch: 'master'
  gem 'thin'# , :github => 'krzcho/thin', :branch => 'master'
end

platforms :ruby do
  group :production do
    gem 'unicorn'
    gem 'daemon-spawn'
    gem 'daemons'
  end
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
