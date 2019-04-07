# -*- mode: ruby -*-
# vi: set ft=ruby :

# Set VirtualBox as default provider
ENV['VAGRANT_DEFAULT_PROVIDER'] = 'virtualbox'

# Function to check whether VM was already provisioned
def provisioned?(vm_name='default', provider="#{ENV['VAGRANT_DEFAULT_PROVIDER']}")
  File.exist?(".vagrant/machines/#{vm_name}/#{provider}/action_provision")
end

["vagrant-proxyconf", "vagrant-disksize", "vagrant-vbguest", "dotenv"].each do |plugin|
  unless Vagrant.has_plugin?(plugin)
    raise plugin + ' is not installed ("vagrant plugin install ' + plugin + '")'
  end
end
Dotenv.load

Vagrant.configure(2) do |config|
  config.vm.box = "bento/centos-7.6"
  config.disksize.size = "40GB"
  config.vm.box_check_update = true
  # do something special if VM was provisioned
  config.vbguest.auto_update = provisioned?

  if Vagrant.has_plugin?("vagrant-proxyconf") && !"#{ENV['http_proxy']}".empty? && !"#{ENV['https_proxy']}".empty?
    puts 'Proxy Settings:'
    puts ' http.proxy ' + "#{ENV['http_proxy']}"
    puts ' https.proxy ' + "#{ENV['https_proxy']}"
    config.proxy.http     = "#{ENV['http_proxy']}"
    config.proxy.https    = "#{ENV['https_proxy']}"
    config.proxy.no_proxy = "localhost,127.0.0.1"
  end
  # Access to Kusanagi from the host
  config.vm.network :forwarded_port, guest: 80, host: 10080 
  config.vm.network :forwarded_port, guest: 443, host: 10443

  # Share folder to the guest VM
  config.vm.synced_folder "./", "/usr/local/src/kusanagi"

  # VirtualBox configuration
  config.vm.provider "virtualbox" do |vb|
    vb.cpus = 1
    vb.memory = 2048
    # Workaround for https://www.virtualbox.org/ticket/15705
    vb.customize ['modifyvm', :id, '--cableconnected1', 'on']
    #vb.gui = true
  end

  # Setup the system with a shell script
  config.vm.provision :shell, keep_color: true, path: "bootstrap.sh"
  config.vm.hostname = "kusanagi-dev"
end
