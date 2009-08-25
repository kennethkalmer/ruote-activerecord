module Ruote
  module ActiveRecord
    # Abstract class to allow for the use of separate database connections
    # to the tables used by ruote-activerecord.
    class Model < ::ActiveRecord::Base

      self.abstract_class = true
    end
  end
end
