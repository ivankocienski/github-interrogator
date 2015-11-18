
# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'

require File.expand_path("../../config/environment", __FILE__)

require 'rspec/rails'
require 'capybara/rspec'
#require 'common'

RSpec.configure do |rspec|

  #rspec.include FactoryGirl::Syntax::Methods

  rspec.color = true

  rspec.fixture_path = File.join( Rails.root, "spec/fixtures" )

  #rspec.before(:suite) do
  #  DatabaseCleaner.strategy = :transaction
  #  DatabaseCleaner.clean_with(:truncation)
  #end

  #rspec.around(:each) do |example|
  #  DatabaseCleaner.cleaning do
  #    example.run
  #  end
  #end
end

#SimpleCov.start 'rails'
