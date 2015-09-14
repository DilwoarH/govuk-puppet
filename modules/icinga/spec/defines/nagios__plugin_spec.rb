require_relative '../../../../spec_helper'

describe 'icinga::plugin', :type => :define do
  let(:title) { 'bear.sh' }
  let(:params) { {:content => 'bear content'} }

  it do
    is_expected.to contain_file('/usr/lib/nagios/plugins/bear.sh')
      .with_content('bear content')
      .with_mode('0755')
  end
end
