packer {
  required_plugins {
    qemu = {
      version = ">= 1.0.1"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

source "qemu" "ntnx-centos-79-x86_64" {
  iso_url            = "http://centos-distro.cavecreek.net/7.9.2009/isos/x86_64/CentOS-7-x86_64-Minimal-2009.iso"
  iso_checksum       = "file:http://centos-distro.cavecreek.net/7.9.2009/isos/x86_64/sha256sum.txt"
  output_directory   = "ntnx-centos-79-x86_64"
  shutdown_command   = "sudo -S shutdown -P now"
  disk_size          = "100G"
  format             = "qcow2"
  accelerator        = "kvm"
  http_directory     = "http"
  ssh_username       = "root"
  ssh_password       = "nutanix/4u"
  ssh_timeout        = "60m"
  vm_name            = "ntnx-centos-79-x86_64.qcow2"
  net_device         = "virtio-net"
  disk_interface     = "virtio"
  boot_wait          = "10s"
  boot_command       = ["<tab> text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/centos-7.9-ahv-x86_64.cfg<enter><wait>"]
  headless           = true
  disk_detect_zeroes = "unmap"
  skip_compaction    = false
  disk_compression   = true
  vnc_bind_address   = "0.0.0.0"
}

build {
  sources = ["source.qemu.ntnx-centos-79-x86_64"]

  # Post Processors
  post-processors {
    # Generate md5 checksum
    post-processor "checksum" {
      checksum_types      = [ "md5" ]
      keep_input_artifact = true
      output              = "${source.name}/${source.name}.{{.ChecksumType}}.checksum"
    }
  }

  # Run updates & install packages
  provisioner "shell" {
    execute_command    = "sudo -E bash '{{ .Path }}'"
    scripts            = [
                          "scripts/centos/security_updates.sh",
                          "scripts/centos/packages_yum_tools.sh",
                          "scripts/centos/packages_net_tools.sh",
                          "scripts/centos/packages_cloud_init.sh",
                         ]
    expect_disconnect  = false
  }

  # Run scripts to apply Nutanix best practices
  provisioner "shell" {
    execute_command    = "sudo -E bash '{{ .Path }}'"
    scripts            = [
                          "scripts/nutanix/ntnx_kernel_settings.sh",
                          "scripts/nutanix/ntnx_set_max_sectors_kb.sh",
                          "scripts/nutanix/ntnx_set_disk_timeout.sh",
                          "scripts/nutanix/ntnx_iscsi_settings.sh",
                          "scripts/nutanix/ntnx_set_noop.sh",
                          "scripts/nutanix/ntnx_disable_transparent_hugepage.sh",
                         ]
    expect_disconnect  = false
  }

  # Run scripts to prepare to seal the OS image
  provisioner "shell" {
    execute_command    = "sudo -E bash '{{ .Path }}'"
    scripts            = [
                          "scripts/linux-common/cleanup-disk-space.sh",
                          "scripts/linux-common/cleanup-rpm-db.sh",
                          "scripts/linux-common/get_cloud-init_config.sh",
                          "scripts/linux-common/cleanup-network.sh",
                         ]
    expect_disconnect  = false
  }

  provisioner "shell" {
    execute_command    = "sudo -E bash '{{ .Path }}'"
    scripts            = [
                          "scripts/linux-common/cleanup-network.sh",
                          "scripts/linux-sysprep/sysprep-op-dhcp-client-state.sh",
                         ]
    expect_disconnect  = true
  }

  provisioner "shell" {
    execute_command    = "sudo -E bash '{{ .Path }}'"
    scripts            = [
                          "scripts/centos/security_hardening_sshd.sh",
                          "scripts/linux-sysprep/sysprep-op-cloud-init.sh",
                          "scripts/linux-sysprep/sysprep-op-crash-data.sh",
                          "scripts/linux-sysprep/sysprep-op-firewall-rules.sh",
                          "scripts/centos/security_selinux_set_enforcing.sh",
                          "scripts/linux-sysprep/sysprep-op-machine-id.sh",
                          "scripts/linux-sysprep/sysprep-op-package-manager-cache.sh",
                          "scripts/linux-sysprep/sysprep-op-package-manager-db.sh",
                          "scripts/linux-sysprep/sysprep-op-ssh-hostkeys.sh",
                          "scripts/linux-sysprep/sysprep-op-yum-uuid.sh",
                          "scripts/linux-sysprep/sysprep-op-tmp-files.sh",
                          "scripts/linux-sysprep/sysprep-op-logfiles.sh",
                          "scripts/linux-sysprep/sysprep-op-bash-history.sh",
                          "scripts/linux-common/reset-root-password.sh",
                         ]
    expect_disconnect  = false
  }
}
