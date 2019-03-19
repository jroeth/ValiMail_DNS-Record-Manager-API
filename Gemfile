source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.2'

gem 'grape'
gem 'grape-api-generator'
gem 'ipaddress'
gem 'jbuilder', '~> 2.5'
gem 'kaminari-grape', '~> 1.0', '>= 1.0.1'
gem 'puma', '~> 3.11'
gem 'rails', '~> 5.2.2', '>= 5.2.2.1'
gem 'sqlite3', '~> 1.3.6'
gem 'validates_hostname', '~> 1.0'

group :development, :test do
  gem 'rspec'
  gem 'rspec-rails'
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'rubocop'
  gem 'nokogiri'
end

group :development do
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'faker'
  gem 'database_cleaner', '~> 1.5'
  gem 'shoulda-matchers', '~> 3.0', require: false
end
