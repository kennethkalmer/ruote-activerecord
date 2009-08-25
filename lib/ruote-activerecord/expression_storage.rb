require 'ruote/engine/context'
require 'ruote/queue/subscriber'
require 'ruote/storage/base'

module Ruote
  module ActiveRecord

    # ActiveRecord persistence for Ruote expressions (ie engine data)
    #
    # #Expression is the model used by this class.
    class ExpressionStorage

      include EngineContext
      include StorageBase
      include Subscriber

      def context=( c )
        @context = c

        subscribe( :expressions )
      end

      # TOOD: Document
      def find_expressions( query = {} )

        fragments = []
        values = []

        if wfid = query[ :wfid ]
          fragments << [ "wfid LIKE ?" ]
          values    << "%#{wfid}%"
        end

        if expclass = query[ :class ]
          fragments << [ "expclass = ?" ]
          values    << expclass.to_s
        end

        conditions = if fragments.any?
          [ fragments.join(' AND '), *values ]
        else
          nil
        end

        fexps = Model.uncached do
          Expression.all( :conditions => conditions ).map { |fexp|
            fexp.to_ruote_expression( @context )
          }
        end

        if meth = query[:responding_to]
          fexps.delete_if { |fexp| !fexp.respond_to?( meth ) }
        end

        fexps
      end

      def []=( fei, fexp )
        Expression.create_from( fexp )
      end

      def []( fei )
        Model.uncached do
          e = Expression.find_by_fei( fei.to_s )
          e ? e.to_ruote_expression( @context ) : nil
        end
      end

      def delete( fei )
        Expression.delete( fei.to_s )
      end

      def size
        Model.uncached do
          Expression.count
        end
      end
    end
  end
end
