module Ruote
  module ActiveRecord
    class ErrorJournal < ::Ruote::HashErrorJournal

      def context=( c )
        @context = c
        subscribe(:errors)
      end

      def process_errors( wfid )
        ProcessError.wfid( wfid ).map(&:to_ruote_process_error)
      end

      def purge_process( wfid )
        ProcessError.purge( wfid )
      end

      protected

      def record( fei, args )
        arpe = ProcessError.new(
          :wfid => fei.parent_wfid,
          :svalue => args
        )
        arpe.fei = fei.to_s
        arpe.save
      end

      def remove( fei )
        ProcessError.delete( fei.to_s )
      end
    end
  end
end
