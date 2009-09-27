# Reference: http://coderrr.wordpress.com/2009/01/16/monkey-patching-activerecord-to-automatically-release-connections/
#            http://github.com/coderrr/cleanup_connection/blob/master/cleanup_connection_patch.rb
#
# Boils down to the fact that we need Ruote::ActiveRecord::Model to clean up after itself
# when used with the engine in a multi-threaded environment. In ActiveRecord 3.0 this issue
# has been fixed with a much cleaner solution than presented here.
if ActiveRecord::VERSION::STRING < '3.0'

  module ActiveRecord
    module ConnectionAdapters
      class ConnectionPool
        def cleanup_connection
          return yield if Thread.current[:__AR__cleanup_connection]

          begin
            Thread.current[:__AR__cleanup_connection] = true
            yield
          ensure
            release_connection
            Thread.current[:__AR__cleanup_connection] = false
          end
        end
      end
    end

    class Base
      class << self
        def cleanup_connection(&block)
          connection_pool.cleanup_connection(&block)
        end

        # comment out this redefinition once you've wrapped all necessary methods
        alias_method :connection_without_cleanup_connection_check, :connection
        def connection(*a)
          if ! Thread.current[:__AR__cleanup_connection] && $DEBUG
            puts "connection called outside of cleanup_connection block", caller, "\n"
          end
          connection_without_cleanup_connection_check(*a)
        end
      end
    end
  end

  methods_to_wrap = {
    (class<<ActiveRecord::Base;self;end) => [
      :find, :find_every, :find_by_sql, :transaction, :count, :create, :delete, :count_by_sql,
      :update, :destroy, :cache, :uncached, :quoted_table_name, :columns, :exists?, :update_all,
      :increment_counter, :decrement_counter, :delete_all, :table_exists?, :update_counters,
    ],
    ActiveRecord::Base => [:quoted_id, :valid?],
    ActiveRecord::Associations::AssociationCollection => [:initialize, :find, :find_target, :load_target, :count],
    ActiveRecord::Associations::HasAndBelongsToManyAssociation => [:create],
    ActiveRecord::Associations::HasManyThroughAssociation => [:construct_conditions],
    ActiveRecord::Associations::HasOneAssociation => [:construct_sql],
    ActiveRecord::Associations::ClassMethods => [:collection_reader_method, :configure_dependency_for_has_many],
    ActiveRecord::Calculations::ClassMethods => [:calculate],
  }
  methods_to_wrap[Test::Unit::TestSuite] = [:run]  if defined?(Test::Unit::TestSuite)

  #
  # IMPORTANT NOTE
  #
  # I've deviated from the original patch below, by having the chained methods access the
  # connection_pool() method on Ruote::ActiveRecord::Model instead of ActiveRecord::Base,
  # ensuring we only patch our own inner workings for the persistence and not cause any
  # curious side effects for normal ActiveRecord code residing in the same interpreter.

  methods_to_wrap.each do |klass, methods|
    methods.each do |method|
      klass.class_eval do
        alias_method_chain method, :cleanup_connection do |target, punc|
          eval %{
            def #{target}_with_cleanup_connection#{punc}(*a, &b)
              Ruote::ActiveRecord::Model.connection_pool.cleanup_connection do
                #{target}_without_cleanup_connection#{punc}(*a, &b)
              end
            end
          }
        end
      end
    end
  end

end
