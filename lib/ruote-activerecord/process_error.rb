module Ruote
  module ActiveRecord
    class ProcessError < Model
      set_table_name Ruote::ActiveRecord.process_error_table
      set_primary_key :fei
      serialize :svalue

      class << self

        def wfid( wfid )
          query do
            all( :conditions => { :wfid => wfid } )
          end
        end

        def purge( wfid )
          query do
            delete_all( [ "wfid = ?", wfid ] )
          end
        end

      end

      def to_ruote_process_error
        Ruote::ProcessError.new( self.svalue )
      end

    end
  end
end
