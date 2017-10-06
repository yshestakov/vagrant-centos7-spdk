# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'etc'
## working directory?
# imagedir = File.dirname(__FILE__)
## hardcoded?
# imagedir = '/images/libvirt'  
## could parsed from default libvirt pool:
imagedir = `virsh pool-dumpxml default |grep '<path>'|sed -e 's/ *<[^>]*>//g'`.chomp
prefix= 'spdkvm'  # FIXME

Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"
  config.vm.box_check_update = false
  # public network:
  config.vm.network :public_network, :dev => "br1", :mode => "bridge", :type => "bridge"

  # LIBVIRT provider BEGIN
  config.vm.provider :libvirt do |libvirt|
    # libvirt.storage :file, :size => '4G', :type => 'raw'
    libvirt.driver = "kvm"
    # libvirt.driver = "system-x86_64"
    # libvirt.host = 'localhost'
    # libvirt.uri = 'qemu:///system'
    libvirt.memory = 1024
    libvirt.cpus = 1
    libvirt.graphics_ip = '0.0.0.0'
    # libvirt.machine_arch = 'x86_64'
    # libvirt.machine_type = 'pc'
    libvirt.machine_type = 'q35'
    libvirt.emulator_path = '/usr/bin/qemu-system-x86_64'
    # libvirt.mgmt_attach = false
  end
  # LIBVIRT provider END
  
  # now, create VMs
  vm_name = 'builder0'
  config.vm.define vm_name do |domain|
    domain.vm.hostname = "#{prefix}-#{vm_name}.mtr.labs.mlnx"
    image_fn = File.join(imagedir, "#{prefix}_#{vm_name}-nvme0.raw")
    unless File.exists? image_fn then
      system("dd", "if=/dev/zero", "of=#{image_fn}", "bs=1M", "count=1000", "conv=sparse")
      pw = Etc.getpwnam('qemu')  # FIXME harcoded username
      File.chown(pw.uid, pw.gid, image_fn)
      File.chmod(0600, image_fn)
    end
    domain.vm.provision "shell", :path => "provision.sh", :privileged => true
    domain.vm.provider :libvirt do |libvirt|
      libvirt.qemuargs :value => '-drive'
      libvirt.qemuargs :value => "file=#{image_fn},if=none,id=mynvme"
      libvirt.qemuargs :value => '-device'
      libvirt.qemuargs :value => 'nvme,drive=mynvme,serial=deadbeef'
      # libvirt.qemuargs :value => "-device"
      # libvirt.qemuargs :value => "intel-iommu"
    end
  end  # end of :builder0 domain (VM)
end
