# -*- mode: ruby -*-
# vi: set ft=ruby :

NETMASK = "21"
BOX = "ubuntu/focal64"
K8S_VERSION = "1.24.0-00"

cluster = {
  "master" => { :ip => "192.168.56.10", :cpus => 2, :mem => 2048, :init => "/vagrant/scripts/setup-master.sh", :env => { "MASTERIP" => "192.168.56.10", "POD_CIDR" => "10.244.0.0/16" } },
  "worker1" => { :ip => "192.168.56.20", :cpus => 2, :mem => 2048, :init => "/vagrant/tmp/join.sh", :env => {} },
  "worker2" => { :ip => "192.168.56.30", :cpus => 2, :mem => 2048, :init => "/vagrant/tmp/join.sh", :env => {} },
  "worker3" => { :ip => "192.168.56.40", :cpus => 2, :mem => 2048, :init => "/vagrant/tmp/join.sh", :env => {} },
}

Vagrant.configure("2") do |config|
  cluster.each_with_index do |(hostname, info), index|
    config.vm.define hostname do |node|
      if hostname == "master"
        node.vm.network "forwarded_port", guest: 6443, host: 6443
        node.vm.synced_folder ".kube", "/home/vagrant/.kube", create: true
      end

      node.vm.hostname = hostname
      node.vm.network "private_network", ip: info[:ip], netmask: NETMASK, hostname: true
      node.vm.box = BOX
      node.vm.provider "virtualbox" do |hv|
        hv.name = hostname
        hv.memory = info[:mem]
        hv.cpus = info[:cpus]
        hv.linked_clone = true
      end

      node.vm.provision "shell", path: "scripts/disable-swap.sh"
      node.vm.provision "shell", path: "scripts/install-containerd.sh"
      node.vm.provision "shell", path: "scripts/install-k8s.sh", env: { "K8S_VERSION" => K8S_VERSION }
      node.vm.provision "shell", inline: "bash #{info[:init]}", env: info[:env]
    end
  end
end
