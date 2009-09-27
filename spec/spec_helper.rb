begin
  require 'spec'
rescue LoadError
  require 'rubygems' unless ENV['NO_RUBYGEMS']
  gem 'rspec'
  require 'spec'
end

if File.directory?( File.dirname(__FILE__) + '/../../ruote' )
  $:.unshift( File.dirname(__FILE__) + '/../../ruote/lib' )
end

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'ruote-activerecord'

require 'ruote/fei'
require 'ruote/workitem'
require 'ruote/exp/expression_map'

# Database credentials
Ruote::ActiveRecord.configuration = {
  :adapter => 'mysql',
  :database => 'test',
  :username => 'root'
}
#Ruote::ActiveRecord::Model.logger = Logger.new( STDOUT )

Spec::Runner.configure do |config|

  config.before(:all) do
    Ruote::ActiveRecord.connect!
    Ruote::ActiveRecord::Schema.reset!
  end

  config.before(:each) do
    Ruote::ActiveRecord::Schema.truncate!
  end
end

# Create a new expression on the fly
def build_expression( exp_id, options = {} )
  options.reverse_merge!(
    :wfid => '1234-5678',
    :class => Ruote::Exp::SequenceExpression
  )

  fei = Ruote::FlowExpressionId.from_h(
    'engine_id' => 'toto',
    'wfid' => options[:wfid],
    'expid' => exp_id
  )

  options[:class].new(
    nil, fei, nil, [ 'sequence', {}, [] ], {}, Ruote::Workitem.new
  )
end

def build_workitem( wfid, exp_id, participant_name, fields )
  fei = Ruote::FlowExpressionId.from_h(
    'engine_id' => 'my_engine', 'wfid' => wfid, 'expid' => exp_id
  )

  wi = Ruote::Workitem.new
  wi.fei = fei
  wi.fields = fields
  wi.participant_name = participant_name

  wi
end
