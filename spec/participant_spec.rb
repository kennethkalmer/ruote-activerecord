require File.dirname(__FILE__) + '/spec_helper'

describe Ruote::ActiveRecord::Participant do
  before(:each) do
    @participant = Ruote::ActiveRecord::Participant.new
  end

  it "should be able to consume workitems" do
    wi = build_workitem( '1234-5678', '0_0', 'toto', { :a => 'A'} )

    @participant.consume( wi )

    Ruote::ActiveRecord::WorkItem.count.should be(1)
    Ruote::ActiveRecord::WorkItem.first.last_modified.should_not be_nil
  end

  it "should be able to cancel workitems" do
    wi = build_workitem( '1234-5678', '0_0', 'toto', { :a => 'A'} )

    @participant.consume( wi )

    @participant.cancel( wi.fei )

    Ruote::ActiveRecord::WorkItem.count.should be(0)

  end

  it "should support store names" do
    wi = build_workitem( '1234-5678', '0_0', 'bob', { :b => 'B' } )
    @participant.consume( wi )

    @participant.store_name = 'alice_store'

    wi = build_workitem( '1234-6789', '0_0', 'alice', { :a => 'A' } )
    @participant.consume( wi )

    @participant.size.should be(1)

    Ruote::ActiveRecord::WorkItem.all.map(&:store_name).should == [ nil, 'alice_store' ]
  end

  it "should support workitems without a key field"
  it "should support workitems with a key field"
end

