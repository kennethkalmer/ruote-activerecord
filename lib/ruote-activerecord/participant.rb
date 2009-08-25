require 'ruote/engine/context'
require 'ruote/part/local_participant'

module Ruote
  module ActiveRecord
    class Participant

      include EngineContext
      include LocalParticipant

      attr_accessor :store_name

      def initialize( options = {} )
        @workitem_class = WorkItem
        @store_name = options[:store_name]
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

      def size
        @workitem_class.count( :conditions => { :store_name => @store_name } )
      end

      private

      def destroy( fei )
        wi = Model.uncached { WorkItem.find_by_fei( fei.to_s ) }
        wi.destroy unless wi.nil?
      end
    end
  end
end
