module Ruote
  module ActiveRecord
    class Expression < Model
      set_table_name Ruote::ActiveRecord.expression_table
      set_primary_key :fei
      serialize :svalue

      class << self

        # Save an expression
        def create_from( fexp )

          e = Model.query { find_or_create_by_fei( fexp.fei.to_s ) }
          e.wfid = fexp.fei.parent_wfid
          e.expclass = fexp.class.name
          e.svalue = fexp

          e.save
        end

        def purge
          Model.query { delete_all }
        end

      end

      def to_ruote_expression( context )
        fe = self.svalue
        fe.context = context
        fe
      end
    end
  end
end
