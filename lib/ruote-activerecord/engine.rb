require 'ruote/engine/fs_engine'

module Ruote
  module ActiveRecord

    # A storage engine for ruote that uses ActiveRecord as a storage backend
    # for expressions.
    class Engine < FsPersistedEngine

      protected

      def build_expression_storage
        init_storage( Ruote::ActiveRecord::ExpressionStorage )
      end
    end
  end
end
