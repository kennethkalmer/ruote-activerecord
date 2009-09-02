require File.dirname(__FILE__) + '/spec_helper.rb'

describe Ruote::ActiveRecord do

  it "should take have a configuration hash" do
    Ruote::ActiveRecord.configuration.should be_a( Hash )
  end

  it "should have a default name for the expression table" do
    Ruote::ActiveRecord.expression_table.should == 'ruote_expressions'
  end

  it "should have a default name for the workitem table" do
    Ruote::ActiveRecord.workitem_table.should == 'ruote_workitems'
  end
end
