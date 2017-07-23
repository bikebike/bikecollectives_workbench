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
# replace this once these changes are merged in sorcery
gem 'sorcery', git: 'https://github.com/tg90nor/sorcery.git', branch: 'make-facebook-provider-use-json-token-parser'
gem 'carrierwave'
gem 'carrierwave-imageoptimizer'
gem 'mini_magick'
gem 'activerecord-session_store'
gem 'premailer-rails'
gem 'sidekiq'
gem 'letter_opener'
gem 'launchy'
gem 'geocoder'

gem 'lingua_franca', git: 'https://github.com/lingua-franca/lingua_franca.git', branch: 'master'
gem 'bikecollectives_core', git: 'https://github.com/bikebike/bikecollectives_core.git', branch: 'master'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'meta_request'
  
  gem 'eventmachine', git: 'https://github.com/krzcho/eventmachine', branch: 'master'
  gem 'thin'
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
