module Ruote
  module ActiveRecord
    # Abstract class to allow for the use of separate database connections
    # to the tables used by ruote-activerecord.
    class Model < ::ActiveRecord::Base

      self.abstract_class = true

      class << self

        if ::ActiveRecord::VERSION::STRING < '3.0'

          # Single place to run all queries through. Responsible for bypassing the
          # ActiveRecord query cache as well as using the connection pool
          def query( &block )
            # No caching
            uncached do
              # No connection pool tricks, we're using the monkey patch
              yield
            end
          end

        else

          # Single place to run all queries through. Responsible for bypassing the
          # ActiveRecord query cache as well as using the connection pool
          def query( &block )
            uncached do
              # Use the connection pool
              connection_pool.with_connection(&block)
            end
          end

        end

      end
    end
  end
end
