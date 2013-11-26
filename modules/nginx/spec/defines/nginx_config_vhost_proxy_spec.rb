require_relative '../../../../spec_helper'

describe 'nginx::config::vhost::proxy', :type => :define do
  let(:title) { 'rabbit' }
  let(:pre_condition) { 'Logster::Cronjob <||>' }

  context 'with a list of upstreams' do
    let(:params) {{
      :to => ['a.internal', 'b.internal', 'c.internal'],
    }}

    it 'should install a proxy vhost' do
      should contain_nginx__config__site('rabbit')
        .with_content(/server a\.internal;/)
        .with_content(/server b\.internal;/)
        .with_content(/server c\.internal;/)
    end

    it { should contain_nginx__config__site('rabbit')
      .with_content(/^\s+proxy_pass http:\/\/rabbit-proxy;$/) }

    it { should contain_logster__cronjob('nginx-vhost-rabbit')
      .with_prefix('nginx_logs.rabbit') }

  end

  context 'with to_ssl true' do
    let(:params) {{
      :to     => ['a.internal', 'b.internal', 'c.internal'],
      :to_ssl => true,
    }}

    it 'should install a proxy vhost' do
      should contain_nginx__config__site('rabbit')
        .with_content(/server a\.internal:443;/)
        .with_content(/server b\.internal:443;/)
        .with_content(/server c\.internal:443;/)
    end

    it { should contain_nginx__config__site('rabbit')
      .with_content(/^\s+proxy_pass https:\/\/rabbit-proxy;$/) }

  end

  context 'with intercept_errors true' do
    let(:params) do
      {
        :to => ['a.internal'],
        :intercept_errors => true,
      }
    end

    it 'should install simple_error_pages' do
      should contain_nginx__config__site('rabbit')
        .with_content(/include \/etc\/nginx\/simple_error_pages\.conf;/)
    end
  end

end
