require 'ruote/engine/context'
require 'ruote/part/local_participant'

module Ruote
  module ActiveRecord
    class Participant

      include EngineContext
      include LocalParticipant

      def initialize( options = {} )
        @workitem_class = WorkItem
      end

      def consume( workitem )

        kf = if @key_field and expstorage and @key_field.match(/\$\{[^\}]+\}/)
          Ruote.dosub(@key_field, expstorage[workitem.fei], workitem)
        elsif @key_field
           workitem.fields[@key_field]
        else
          nil
        end

        kf = kf ? kf.to_s : nil

        @workitem_class.create_from_workitem(
          workitem, :store_name => @store_name, :key_field => kf
        )
      end

      def cancel( fei, flavour = nil )
        destroy( fei )
      end

      private

      def destroy( fei )
        wi = Model.uncached { WorkItem.find_by_fei( fei.to_s ) }
        wi.destroy unless wi.nil?
      end
    end
  end
end
