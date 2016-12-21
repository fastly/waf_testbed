#
# apache2+mod_security vagrant box
#
Vagrant.configure(2) do |config|
  config.ssh.forward_agent = true
  config.vm.define 'modsec0' do |modsec_conf|
    modsec_conf.vm.box = 'ubuntu/trusty64'
    modsec_conf.berkshelf.enabled = true
    modsec_conf.berkshelf.berksfile_path = './Berksfile'
    modsec_conf.vm.network 'private_network', ip: '192.168.50.75'
    modsec_conf.vm.provider 'virtualbox' do |v|
      v.memory = 512
      v.cpus = 2
    end
    modsec_conf.vm.provision :chef_solo do |chef|
      chef.add_recipe('waf_testbed::default')
    end
  end
end
