require File.dirname(__FILE__) + '/spec_helper'

describe Ruote::ActiveRecord::ExpressionStorage do

  before(:each) do
    @expression_storage = Ruote::ActiveRecord::ExpressionStorage.new
  end

  it "should be able to store expressions" do
    fexp = build_expression('0_0')

    @expression_storage[ fexp.fei ] = fexp

    @expression_storage.size.should be(1)
  end

  it "should be able to remove expressions" do
    fexp = build_expression('0_0')

    @expression_storage[ fexp.fei ] = fexp
    @expression_storage.delete( fexp.fei )

    @expression_storage.size.should be(0)
  end

  describe "find expressions" do

    it "be flow expression id" do
      fexp = build_expression('0_0')
      @expression_storage[ fexp.fei ] = fexp

      @expression_storage[ fexp.fei ].fei.should == fexp.fei
    end

    it "by workflow id" do
      fexp = build_expression('0_0', :wfid => 'abcd-5')
      @expression_storage[ fexp.fei ] = fexp

      fexp = build_expression('0_0', :wfid => 'abcd-5_0')
      @expression_storage[ fexp.fei ] = fexp

      @expression_storage.find_expressions( :wfid => 'abcd-5' ).size.should be(2)

      @expression_storage.find_expressions( :wfid => 'abcd-5').first.should be_a( Ruote::SequenceExpression )
    end

    it "by expression class" do
      fexp = build_expression('0_0', :class => Ruote::WaitExpression )
      @expression_storage[ fexp.fei ] = fexp

      @expression_storage.find_expressions( :class => Ruote::WaitExpression ).size.should be(1)
      @expression_storage.find_expressions( :class => Ruote::SequenceExpression ).should be_empty
    end

    it "by testing for respond_to" do
      fexp = build_expression('0_0', :wfid => 'abcd-5')
      @expression_storage[ fexp.fei ] = fexp

      fexp = build_expression('0_0', :class => Ruote::WaitExpression )
      @expression_storage[ fexp.fei ] = fexp

      @expression_storage.find_expressions( :responding_to => :reschedule ).size.should be(1)
    end
  end
end
