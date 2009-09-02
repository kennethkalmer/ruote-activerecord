module Ruote
  module ActiveRecord
    # Abstract class to allow for the use of separate database connections
    # to the tables used by ruote-activerecord.
    class Model < ::ActiveRecord::Base

      self.abstract_class = true

      class << self

        # Single place to run all queries through. Responsible for bypassing the
        # ActiveRecord query cache as well as using the connection pool
        def query( &block )
          # No caching
          uncached do
            # Use the connection pool
            connection_pool.with_connection do
              yield
            end
          end
        end
      end
    end
  end
end
