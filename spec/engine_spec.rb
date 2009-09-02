require File.dirname(__FILE__) + '/spec_helper'

describe Ruote::ActiveRecord::Engine do

  it "should use ActiveRecord for expression storage" do
    engine = Ruote::ActiveRecord::Engine.new

    # TODO: Is this really the right way to test it ?
    engine.context[:s_expression_storage].should be_a( Ruote::ActiveRecord::ExpressionStorage )
  end
end
