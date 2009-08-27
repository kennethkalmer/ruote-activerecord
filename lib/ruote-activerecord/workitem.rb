module Ruote
  module ActiveRecord
    class Workitem < Model
      set_table_name Ruote::ActiveRecord.workitem_table
      set_primary_key :fei

      class << self

        def create_from_workitem( workitem, options = {} )

          wi = find_by_fei( workitem.fei.to_s ) || new
          wi.fei = workitem.fei.to_s
          wi.wfid = workitem.fei.parent_wfid
          wi.engine_id = workitem.fei.engine_id
          wi.participant_name = workitem.participant_name
          wi.wi_fields = workitem.fields

          wi.store_name = options[:store_name]
          wi.key_field = options[:key_field]

          wi.save
        end

        def search( keyword, *store_names )
          store_names.flatten!

          conditions = []
          values = []

          conditions << "keywords LIKE ?"
          values << "%#{keyword}%"

          if store_names.any?
            conditions << "store_name IN (?)"
            values << store_names
          end

          Model.uncached do
            all( :conditions => [ conditions.join( ' AND '), *values ] )
          end
        end
      end

      protected

      def before_create
        self.dispatch_time = Time.now
      end

      def before_save
        self.last_modified = Time.now
        self.keywords = determine_keywords( self.participant_name, self.wi_fields )
      end

      def determine_keywords( participant_name, wi_fields )
        dk( wi_fields.merge( 'participant' => participant_name ) ).gsub(/\|+/, '|')
      end

      # TODO: rename this to make more sense
      def dk( object )
        case object
        when Hash
          object = object.stringify_keys
          "|#{object.keys.sort.collect { |k| "#{dk(k)}:#{dk(object[k])}" }.join('|')}|"
        when Array
          "|#{object.collect { |e| dk(e) }.join('|')}|"
        else
          object.to_s.gsub(/[\|:]/, '')
        end
      end
    end
  end
end
