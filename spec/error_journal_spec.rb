require File.dirname(__FILE__) + '/spec_helper'

class TestEngine < Ruote::FsPersistedEngine
  def build_error_journal
    add_service(:s_ejournal, Ruote::ActiveRecord::ErrorJournal)
  end
end

describe Ruote::ActiveRecord::ErrorJournal do

  before(:each) do
    @engine = TestEngine.new
  end

  after(:each) do
    @engine.shutdown
    FileUtils.rm_rf('work')
  end

  it "should record errors and replay them" do
    pdef = Ruote.process_definition :name => 'test' do
      nada
    end

    wfid = @engine.launch( pdef )

    sleep 0.4

    Ruote::ActiveRecord::ProcessError.count.should be(1)
    @engine.process( wfid ).errors.size.should be(1)

    @engine.process( wfid ).errors.first.error_message.should == "unknown expression 'nada'"

    seen = false

    @engine.register_participant :nada do |workitem|
      seen = true
    end

    @engine.replay_at_error( @engine.process( wfid ).errors.first )

    sleep 0.4

    seen.should be_true

    @engine.process( wfid ).should be_nil
    Ruote::ActiveRecord::ProcessError.count.should be(0)
  end

  it "should re-record multiple errors when replayed" do
    pdef = Ruote.process_definition :name => 'test' do
      nada
    end

    wfid = @engine.launch( pdef )

    sleep 0.4

    first_time = Ruote::ActiveRecord::ProcessError.first.created_at

    sleep 1

    @engine.replay_at_error( @engine.process( wfid ).errors.first )

    sleep 0.4

    Ruote::ActiveRecord::ProcessError.count.should be(1)
    @engine.process( wfid ).errors.size.should be(1)

    first_time.should_not == Ruote::ActiveRecord::ProcessError.first.reload.created_at
  end

  it "should clear up errors when the process is cancelled" do
    pdef = Ruote.process_definition :name => 'test' do
      nada
    end

    wfid = @engine.launch( pdef )

    sleep 0.4

    Ruote::ActiveRecord::ProcessError.count.should be(1)

    @engine.cancel_process( wfid )

    sleep 0.4

    @engine.process( wfid ).should be_nil
    Ruote::ActiveRecord::ProcessError.count.should be(0)
  end
end
