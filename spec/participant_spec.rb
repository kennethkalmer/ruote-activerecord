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

  it "should support store names"
  it "should support keywords" do
    wi = build_workitem( '123', '0_0', 'alice', {
      'animals' => %w{ lion boar beef zebra gnu },
      'cars' => { 'bmw' => true }
    } )

    @participant.consume( wi )

    db_wi = Ruote::ActiveRecord::WorkItem.first
    db_wi.keywords.should == '|animals:|lion|boar|beef|zebra|gnu|cars:|bmw:true|participant:alice|'
  end

  it "should support searching"
  it "should support searching with store names"
  it "should support workitems without a key field"
  it "should support workitems with a key field"
end

