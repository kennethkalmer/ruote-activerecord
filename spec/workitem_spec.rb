require File.dirname(__FILE__) + '/spec_helper'

describe Ruote::ActiveRecord::Workitem do

  describe "and consumed workitems" do
    before(:each) do
      @participant = Ruote::ActiveRecord::Participant.new
    end

    it "should support keywords" do
      wi = build_workitem( '123', '0_0', 'alice', {
        'animals' => %w{ lion boar beef zebra gnu },
        'cars' => { 'bmw' => true }
      } )

      @participant.consume( wi )

      db_wi = Ruote::ActiveRecord::Workitem.first
      db_wi.keywords.should == '|animals:|lion|boar|beef|zebra|gnu|cars:|bmw:true|participant:alice|'
    end

    it "should support searching" do
      wi = build_workitem( '123', '0_0', 'alice', {
        'animals' => %w{ lion boar beef zebra gnu },
        'cars' => { 'bmw' => true }
      } )

      @participant.consume( wi )

      Ruote::ActiveRecord::Workitem.search('bmw:true').size.should be(1)
    end

    it "should support searching with store names" do
      Ruote::ActiveRecord::Workitem.create_from_workitem(
        build_workitem( '123', '0_0', 'alice', { :a => 'A' } ),
        :store_name => 'store0'
      )
      Ruote::ActiveRecord::Workitem.create_from_workitem(
        build_workitem( '124', '0_0', 'alice', { :a => 'A' } ),
        :store_name => 'store1'
      )
      Ruote::ActiveRecord::Workitem.create_from_workitem(
        build_workitem( '125', '0_0', 'bob', { :a => 'A' } ),
        :store_name => 'store0'
      )

      Ruote::ActiveRecord::Workitem.search('a:A').size.should be(3)
      Ruote::ActiveRecord::Workitem.search('a:A', 'store1').size.should be(1)
      Ruote::ActiveRecord::Workitem.search('a:A', [ 'store1' ]).size.should be(1)
      Ruote::ActiveRecord::Workitem.search('a:A', [ 'store0' ]).size.should be(2)
    end

    it "should convert back to a ruote workitem" do
      wi = build_workitem('1234-5678', '0_0', 'alice', { :a => 'A' })
      Ruote::ActiveRecord::Workitem.create_from_workitem( wi, :store_name => 'store0' )

      db_wi = Ruote::ActiveRecord::Workitem.first

      wi = db_wi.to_ruote_workitem
      wi.should be_a( Ruote::Workitem )
      wi.fields.should == { :a => 'A' }
    end

    it "should overwrite duplicate workitems" do
      wi = build_workitem('1234-5678', '0_0', 'alice', { :a => 'A' })
      Ruote::ActiveRecord::Workitem.create_from_workitem( wi, :store_name => 'store0' )

      Ruote::ActiveRecord::Workitem.count.should be(1)

      lambda {
        Ruote::ActiveRecord::Workitem.create_from_workitem( wi, :store_name => 'store0')
      }.should_not raise_error

      Ruote::ActiveRecord::Workitem.count.should be(1)
    end
  end
end
