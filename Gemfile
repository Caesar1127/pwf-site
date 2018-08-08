source 'https://rubygems.org'
ruby "2.4.2"

gem 'rails', '5.2'
gem 'bootsnap'
gem 'devise'
gem "simple_form"
gem 'inherited_resources'
gem 'simple_enum', git: 'git://github.com/lwe/simple_enum.git'
gem 'kaminari'
gem 'activerecord-import'
gem 'font-awesome-sass', '~> 5.2.0'
gem 'pg'
gem 'puma', '~> 3.7'
gem 'activeadmin'
gem 'stripe'
gem 'paypal-express'
gem "aws-sdk-s3",  require: false
gem 'rmagick'
gem "prawn"#, :git => "git://github.com/prawnpdf/prawn.git"
gem 'prawn-table' #, '~> 0.1.0'
gem 'bootstrap', '~> 4.1.1'
gem 'jquery-rails'
gem "chosen-rails"


group :development, :test do
  gem "better_errors"
  gem "hirb"
  gem 'rspec'
  gem "rspec-rails"
  gem 'factory_bot' 
  gem "factory_bot_rails"
  gem 'taps'
  gem "faker"
  gem "populator"
  gem "pry"
  #gem "fakeweb"  causes failure in carrierwave_direct
  gem "letter_opener"

end

group :test do
  gem 'capybara'
  gem "guard-rspec"
  gem "database_cleaner"
  gem "launchy"
  gem 'simplecov', :require => false
  gem 'selenium-webdriver'
end
