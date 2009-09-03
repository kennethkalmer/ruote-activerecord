# This file is used when running the ruote integration test suites.

Ruote::ActiveRecord.configuration = {
  :adapter => 'mysql',
  :database => 'test',
  :username => 'root'
}
Ruote::ActiveRecord::Schema.create!

ruote_engine_class = Ruote::ActiveRecord::Engine
