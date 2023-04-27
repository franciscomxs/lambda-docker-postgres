require 'sequel'
require 'pg'
require 'pry'

# Connect to database
DB = Sequel.connect(ENV['DATABASE_URL'])

Dir['./lib/repositories/*.rb'].each { |f| require f }
