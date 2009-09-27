require File.dirname(__FILE__) + '/spec_helper'

describe Ruote::ActiveRecord::Ticket do

  it "can be drawn" do
    ticket = Ruote::ActiveRecord::Ticket.draw('ticketer', 'target')
    ticket.created_at.should_not be_nil
    ticket.should be_consumable
  end

  it "can draw multiple tickets" do
    t1 = Ruote::ActiveRecord::Ticket.draw('ticketer0', 'target')
    t2 = Ruote::ActiveRecord::Ticket.draw('ticketer1', 'target')

    t1.should be_consumable
    t2.should_not be_consumable

    t1.destroy

    t2.should be_consumable
  end

  it "can be discarded" do
    Ruote::ActiveRecord::Ticket.draw('a', 't0')
    Ruote::ActiveRecord::Ticket.draw('b', 't0')
    Ruote::ActiveRecord::Ticket.draw('b', 't1')

    Ruote::ActiveRecord::Ticket.count.should be(3)

    Ruote::ActiveRecord::Ticket.discard_all('t1')

    Ruote::ActiveRecord::Ticket.count.should be(2)

    Ruote::ActiveRecord::Ticket.discard_all('t0')

    Ruote::ActiveRecord::Ticket.count.should be(0)
  end

  it "should be unique" do
    Ruote::ActiveRecord::Ticket.draw('ticketer', 'target')

    lambda {
      lambda {
        Ruote::ActiveRecord::Ticket.draw('ticketer', 'target')
      }.should raise_error( ActiveRecord::StatementInvalid )
    }.should_not change( Ruote::ActiveRecord::Ticket, :count )
  end

  it "should run in harmony" do
    timeline = []

    job = lambda do |holder, sec|
      ticket = Ruote::ActiveRecord::Ticket.draw( holder, 'ticket' )

      loop do
        timeline << [ holder, :drawn, ticket.id ]

        sleep( sec )

        timeline << [ holder, :wake_up ]
        timeline << [ holder, :consumable?, ticket.consumable? ]

        if ticket.consumable?
          timeline << [ holder, :job_done ]
          ticket.consume
          break
        end

        sleep 0.1
      end
    end

    t0 = Thread.new { job.call( 'a', 0.10 ) }
    t1 = Thread.new { job.call( 'b', 0.05 ) }

    sleep 1

    Ruote::ActiveRecord::Ticket.count.should be(0)

    timeline.select { |e| e == ['a', :job_done] }.size.should be(1)
    timeline.select { |e| e == ['b', :job_done] }.size.should be(1)
  end
end
