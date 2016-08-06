describe service('apache2-default') do
  it { should be_enabled }
  it { should be_running }
end

describe port(80) do
  it { should be_listening }
end

describe package('libapache2-mod-security2') do
  it { should be_installed }
end

#
# NB: It's possible that the engine is running in detection
# mode. The following command should result in a log being
# generated at the very least.
#
describe command('curl -X__FOOBAZ localhost') do
#  its(:stdout) { should match '<title>403 Forbidden</title>' }
  its(:exit_status) { should eq 0 }
end

describe command('curl -XGET localhost') do
  its(:stdout) { should match ' <h1>Testing Site</h1>' }
  its(:exit_status) { should eq 0 }
end

describe command('curl -X_BOGUS_HEADER_TLS -k https://localhost') do
  its(:exit_status) { should eq 0 }
end

describe file('/var/log/apache2/modsec_audit.log') do
  it { should be_file }
  its (:content) { should match 'data "WAF testing: Got unauthorized method: __FOOBAZ"\]' }
end

describe file('/var/log/apache2/modsec_audit.log') do
  it { should be_file }
  its (:content) { should match 'data "WAF testing: Got unauthorized method: _BOGUS_HEADER_TLS"\]' }
end
