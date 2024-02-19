source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.0'

# Application server
gem 'unicorn'

# Database
gem 'pg'

# Country gem
gem 'carmen-rails'

# Model related gems
gem 'omniauth'
gem 'omniauth-facebook', '4.0.0'
gem 'omniauth-google-oauth2'
gem 'omniauth-openid'
gem 'koala'
gem 'statesman'
gem 'kaminari'
gem 'active_model_serializers'
gem 'paper_trail', '~> 3.0.6'
gem 'friendly_id', '~> 5.1.0'
gem 'date_validator'

# Payment related gems
gem 'braintree'

# Format related gems
gem 'jbuilder', '~> 2.0'

# Assets and template related gems
gem 'jquery-rails'
gem 'slim'
gem 'font-awesome-sass'
gem 'i18n-js', git: 'git@github.com:fnando/i18n-js.git'
gem 'asset_sync'
gem 'refile', require: 'refile/rails'
gem 'refile-s3'

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Background job related gems
gem 'sidekiq'
gem 'sidekiq-failures'
gem 'sinatra'
gem 'sidetiq'

# Geolocation
gem 'geoip'
gem 'geocoder'

# Others
gem 'dotenv-rails'
gem 'chronic'
gem 'honeybadger'
gem 'open4'
# gem 'curb'
gem 'gon'
gem 'humanize_boolean'

# Analytics
gem 'analytics-ruby', git: 'git@github.com:segmentio/analytics-ruby.git'
gem 'referer-parser', '~> 0.3.0'

# Others
gem 'rack-reverse-proxy', require: 'rack/reverse_proxy'

group :assets do
  gem 'sass-rails'
  gem 'uglifier', '>= 1.3.0'
  gem 'coffee-rails', '~> 4.1.0'
  gem 'therubyracer', platforms: :ruby
end

group :development do
  gem 'awesome_print'
  gem 'hirb'
  gem 'better_errors'
  gem 'meta_request'
  gem 'letter_opener'
  gem 'letter_opener_web', '~> 1.2.0'
  gem 'priscilla'

  gem 'capistrano'
  gem 'capistrano-rails'
  gem 'capistrano-ext'
  gem 'rvm-capistrano'
  gem 'pry'
end

group :development, :test do
  gem 'byebug'
  gem 'web-console', '~> 2.0'
  gem 'spring'
  gem 'libnotify'

  gem 'rspec-rails'
  gem 'guard-rspec'
  gem 'database_cleaner'
  gem 'simplecov', require: false
  gem 'fabrication'
  gem 'faker'
  gem 'bullet'
  gem 'rr'
  gem 'capybara'
  gem 'poltergeist'
  gem 'selenium-webdriver'
  gem 'launchy'
end
