require File.dirname(__FILE__) + '/spec_helper'

describe Ruote::ActiveRecord::Participant do
  before(:each) do
    @participant = Ruote::ActiveRecord::Participant.new
  end

  it "should be able to consume workitems" do
    wi = build_workitem( '1234-5678', '0_0', 'toto', { :a => 'A'} )

    @participant.consume( wi )

    Ruote::ActiveRecord::Workitem.count.should be(1)
    Ruote::ActiveRecord::Workitem.first.last_modified.should_not be_nil
  end

  it "should be able to update workitems" do
    wi = build_workitem( '1234-5678', '0_0', 'toto', { :a => 'A'} )

    @participant.consume( wi )

    Ruote::ActiveRecord::Workitem.count.should be(1)
    Ruote::ActiveRecord::Workitem.first.last_modified.should_not be_nil

    @participant.update( wi )

    Ruote::ActiveRecord::Workitem.count.should be(1)
    Ruote::ActiveRecord::Workitem.first.last_modified.should_not be_nil
  end

  it "should be able to cancel workitems" do
    wi = build_workitem( '1234-5678', '0_0', 'toto', { :a => 'A'} )

    @participant.consume( wi )

    @participant.cancel( wi.fei )

    Ruote::ActiveRecord::Workitem.count.should be(0)
  end

  it "should support purging itself" do
    wi = build_workitem( '1234-5678', '0_0', 'toto', { :a => 'A'} )

    @participant.consume( wi )

    @participant.purge

    Ruote::ActiveRecord::Workitem.count.should be(0)
  end

  it "should support store names" do
    wi = build_workitem( '1234-5678', '0_0', 'bob', { :b => 'B' } )
    @participant.consume( wi )

    @participant.store_name = 'alice_store'

    wi = build_workitem( '1234-6789', '0_0', 'alice', { :a => 'A' } )
    @participant.consume( wi )

    @participant.size.should be(1)

    Ruote::ActiveRecord::Workitem.all.map(&:store_name).should == [ nil, 'alice_store' ]
  end

  it "should support workitems without a key field" do
    wi = build_workitem( '1234-5678', '0_0', 'alice', { :b => 'B' })
    @participant.consume( wi )

    Ruote::ActiveRecord::Workitem.first.key_field.should be_nil
  end

  describe "with a key field" do
    before(:each) do
      @participant = Ruote::ActiveRecord::Participant.new( :key_field => 'brand' )
      @participant.context = {}
    end

    it "should mark workitems accordingly" do
      %w{ alfa-romeo citroen maserati citroen }.each_with_index do |make, i|
        wi = build_workitem('1234-567', "0_#{i}", 'alice', { :a => 'A', 'brand' => make })
        @participant.consume( wi )
      end

      Ruote::ActiveRecord::Workitem.count(:conditions => { :key_field => 'alfa-romeo'}).should be(1)
      Ruote::ActiveRecord::Workitem.count(:conditions => { :key_field => 'citroen'}).should be(2)
    end
  end
end

