module Ruote
  module ActiveRecord
    class Ticket < Model
      set_table_name Ruote::ActiveRecord.ticket_table

      class << self

        def draw( holder, target )
          ticket = new( :holder => holder, :target => target )
          ticket.save ? ticket : nil
        end

        def discard_all( target )
          Model.query { delete_all( :target => target ) }
        end

      end

      alias :consume :destroy

      def consumable?
        first_ticket = Model.query { self.class.first( :conditions => { :target => self.target }, :order => 'id ASC' ) }

        first_ticket.id == self.id
      end
    end
  end
end
