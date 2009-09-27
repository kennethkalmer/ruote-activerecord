# This file is used when running the ruote integration test suites.

Ruote::ActiveRecord.configuration = {
  :adapter => 'mysql',
  :database => 'test',
  :username => 'root',
  :pool => 5
}
Ruote::ActiveRecord::Schema.create!

#Ruote::ActiveRecord::Model.logger = Logger.new( STDOUT )

ruote_engine_class = Ruote::ActiveRecord::Engine
