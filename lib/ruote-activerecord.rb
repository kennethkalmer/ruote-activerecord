$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

begin
  require 'activerecord'
rescue LoadError
  require 'rubygems'
  gem 'activerecord', '>=2.3.3'
  require 'activerecord'
end

if ActiveRecord::VERSION::STRING < '2.3.3'
  raise "ruote-activerecord requires ActiveRecord 2.3.3 or later"
end

Dir[ File.join( File.dirname(__FILE__), 'ruote-activerecord', 'patches', '*.rb' ) ].each do |patch|
  require File.join('ruote-activerecord', 'patches', File.basename( patch, '.rb' ) )
end

module Ruote
  module ActiveRecord
    VERSION = '0.0.1'

    autoload :Expression,        'ruote-activerecord/expression'
    autoload :ExpressionStorage, 'ruote-activerecord/expression_storage'
    autoload :Participant,       'ruote-activerecord/participant'
    autoload :Engine,            'ruote-activerecord/engine'
    autoload :Model,             'ruote-activerecord/model'
    autoload :Schema,            'ruote-activerecord/schema'
    autoload :Workitem,          'ruote-activerecord/workitem'
    autoload :Ticket,            'ruote-activerecord/ticket'

    # ActiveRecord configuration hash
    mattr_accessor :configuration
    self.configuration = {}

    # The table name used for storing expressions
    mattr_accessor :expression_table
    self.expression_table = 'ruote_expressions'

    # The table name used for storing workitems
    mattr_accessor :workitem_table
    self.workitem_table = 'ruote_workitems'

    # The table name used for storing tickets
    mattr_accessor :ticket_table
    self.ticket_table = 'ruote_tickets'

    class << self

      # Connect to the database
      def connect!
        Model.establish_connection( self.configuration )
      end
    end
  end
end
