module Ruote
  module ActiveRecord
    class Schema < ::ActiveRecord::Migration
      class << self

        # Truncate the tables
        def truncate!
          Ruote::ActiveRecord::Expression.delete_all
          Ruote::ActiveRecord::WorkItem.delete_all
        end

        # Create the tables required for ActiveRecord storage
        def create!
          create_table Ruote::ActiveRecord.expression_table, :id => false, :force => true do |t|
            t.string :fei, :null => false
            t.string :wfid
            t.string :expclass
            t.text :svalue, :null => false

            t.primary_key :fei
          end

          add_index Ruote::ActiveRecord.expression_table, :fei
          add_index Ruote::ActiveRecord.expression_table, :wfid

          create_table Ruote::ActiveRecord.workitem_table, :id => false, :force => true do |t|
            t.string :fei, :null => false
            t.string :wfid, :null => false
            t.string :engine_id, :null => false
            t.string :participant_name, :null => false
            t.string :wi_fields, :null => false
            t.string :keywords, :null => false
            t.string :key_field
            t.datetime :dispatch_time, :null => false
            t.datetime :last_modified, :null => false
            t.string :store_name

            t.primary_key :fei
          end

          add_index Ruote::ActiveRecord.workitem_table, :wfid
          add_index Ruote::ActiveRecord.workitem_table, :engine_id
          add_index Ruote::ActiveRecord.workitem_table, :participant_name
          add_index Ruote::ActiveRecord.workitem_table, :key_field
          add_index Ruote::ActiveRecord.workitem_table, :store_name
        end

        # Same as #create, without any messages printed to STDOUT
        def reset!
          suppress_messages { create! }
        end

        # Prefer our own database connection over that off ActiveRecord::Base
        def connection #:nodoc:
          Ruote::ActiveRecord.connect! unless Ruote::ActiveRecord::Model.connected?
          Ruote::ActiveRecord::Model.connection
        end
      end
    end
  end
end
