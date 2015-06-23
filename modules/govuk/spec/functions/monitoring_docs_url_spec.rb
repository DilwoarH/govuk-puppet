require_relative '../../../../spec_helper'

# Put module's plugins on LOAD_PATH.
dir = File.expand_path('../../', File.dirname(__FILE__))
$LOAD_PATH.unshift File.join(dir, 'lib')

describe 'monitoring_docs_url' do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it 'should raise an error when no arguments are passed' do
    expect { scope.function_monitoring_docs_url([]) }.to raise_error(ArgumentError, /given 0 for 1$/)
  end

  it 'should return a URL with the correct anchor' do
    broken_thing_url = 'https://github.gds/pages/gds/opsmanual/2nd-line/nagios.html#broken-thing'
    scope.function_monitoring_docs_url(['broken-thing']).should == broken_thing_url
  end
end
