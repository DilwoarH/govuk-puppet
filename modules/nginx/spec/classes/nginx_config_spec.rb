require_relative '../../../../spec_helper'

describe 'nginx::config', :type => :class do
  let(:file_path) { '/etc/nginx/nginx.conf' }
  let(:default_params) {{
    :server_names_hash_max_size => '512',
    :denied_ip_addresses => []
  }}

  describe 'server_names_has_max_size' do
    let(:params) { default_params.merge({ 
      :server_names_hash_max_size => '1024'
    }) }

    it { is_expected.to contain_file(file_path).with_content(/server_names_hash_max_size 1024;/) }
  end

  describe 'denied_ip_addresses' do
    context 'string param' do
      let(:params) { default_params.merge({ 
        :denied_ip_addresses => '127.0.0.1' 
      })}
      it { is_expected.to contain_file('/etc/nginx/blockips.conf')
        .with_content(<<EOS
deny 127.0.0.1;
EOS
      )}
    end
    
    context 'array param' do
      let(:params) { default_params.merge({ 
        :denied_ip_addresses => [ '127.0.0.1', '127.0.0.2' ] 
      })}
      it { is_expected.to contain_file('/etc/nginx/blockips.conf')
        .with_content(<<EOS
deny 127.0.0.1;
deny 127.0.0.2;
EOS
      )}
    end
  end
    
end
