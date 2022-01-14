packer {
  required_plugins {
    qemu = {
      version = ">= 1.0.1"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

source "qemu" "centos79-lvm" {
  iso_url            = "http://centos-distro.cavecreek.net/7.9.2009/isos/x86_64/CentOS-7-x86_64-Minimal-2009.iso"
  iso_checksum       = "file:http://centos-distro.cavecreek.net/7.9.2009/isos/x86_64/sha256sum.txt"
  output_directory   = "output"
  shutdown_command   = "sudo -S shutdown -P now"
  disk_size          = "50G"
  format             = "qcow2"
  accelerator        = "kvm"
  http_directory     = "http"
  ssh_username       = "root"
  ssh_password       = "nutanix/4u"
  ssh_timeout        = "60m"
  vm_name            = "centos-7.9-x86_64-lvm.qcow2"
  net_device         = "virtio-net"
  disk_interface     = "virtio"
  boot_wait          = "10s"
  boot_command       = ["<tab> text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/centos-7.9-ahv-x86_64-lvm.cfg<enter><wait>"]
  headless           = true
  disk_detect_zeroes = "unmap"
  skip_compaction    = false
  disk_compression   = true
  vnc_bind_address   = "0.0.0.0"
}

build {
  sources = ["centos79-lvm"]
  provisioners = [
    {
      type              = "shell"
      execute_command   = "sudo -E bash '{{ .Path }}'"
      script            = "centos/scripts/security_updates.sh"
      expect_disconnect = false
    },
    {
      type              = "shell"
      execute_command   = "sudo -E bash '{{ .Path }}'"
      script            = "centos/scripts/ntnx_kernel_settings.sh"
      expect_disconnect = false
    },
    {
      type              = "shell"
      execute_command   = "sudo -E bash '{{ .Path }}'"
      script            = "centos/scripts/ntnx_set_max_sectors_kb.sh"
      expect_disconnect = false
    },
    {
      type              = "shell"
      execute_command   = "sudo -E bash '{{ .Path }}'"
      script            = "centos/scripts/ntnx_set_disk_timeout.sh"
      expect_disconnect = false
    },
    {
      type              = "shell"
      execute_command   = "sudo -E bash '{{ .Path }}'"
      script            = "centos/scripts/ntnx_set_noop.sh"
      expect_disconnect = false
    },
    {
      type              = "shell"
      execute_command   = "sudo -E bash '{{ .Path }}'"
      script            = "centos/scripts/ntnx_disable_transparent_hugepage.sh"
      expect_disconnect = false
    },
    {
      type              = "shell"
      execute_command   = "sudo -E bash '{{ .Path }}'"
      script            = "centos/scripts/ntnx_iscsi_settings.sh"
      expect_disconnect = false
    },
    {
      type              = "shell"
      execute_command   = "sudo -E bash '{{ .Path }}'"
      script            = "centos/scripts/ntnx_grub2_mkconfig.sh"
      expect_disconnect = false
    },
    {
      type              = "shell"
      execute_command   = "sudo -E bash '{{ .Path }}'"
      script            = "centos/scripts/packages_yum_tools.sh"
      expect_disconnect = false
    },
    {
      type              = "shell"
      execute_command   = "sudo -E bash '{{ .Path }}'"
      script            = "centos/scripts/packages_cloud_init.sh"
      expect_disconnect = false
    },
    {
      type              = "shell"
      execute_command   = "sudo -E bash '{{ .Path }}'"
      script            = "centos/scripts/packages_net_tools.sh"
      expect_disconnect = false
    },
    {
      type              = "shell"
      execute_command   = "sudo -E bash '{{ .Path }}'"
      script            = "scripts/linux-common/get_cloud-init_config.sh"
      expect_disconnect = false
    },
    {
      type              = "shell"
      execute_command   = "sudo -E bash '{{ .Path }}'"
      script            = "scripts/linux-sysprep/sysprep-op-dhcp-client-state.sh"
      expect_disconnect = true
    },
    {
      type              = "shell"
      execute_command   = "sudo -E bash '{{ .Path }}'"
      script            = "scripts/linux-sysprep/sysprep-op-firewall-rules.sh"
      expect_disconnect = false
    },
    {
      type              = "shell"
      execute_command   = "sudo -E bash '{{ .Path }}'"
      script            = "scripts/linux-sysprep/sysprep-op-machine-id.sh"
      expect_disconnect = false
    },
    {
      type              = "shell"
      execute_command   = "sudo -E bash '{{ .Path }}'"
      script            = "scripts/linux-sysprep/sysprep-op-mail-spool.sh"
      expect_disconnect = false
    },
    {
      type              = "shell"
      execute_command   = "sudo -E bash '{{ .Path }}'"
      script            = "scripts/linux-common/cleanup-network.sh"
      expect_disconnect = true
    },
    {
      type              = "shell"
      execute_command   = "sudo -E bash '{{ .Path }}'"
      script            = "scripts/linux-sysprep/sysprep-op-package-manager-cache.sh"
      expect_disconnect = false
    },
    {
      type              = "shell"
      execute_command   = "sudo -E bash '{{ .Path }}'"
      script            = "scripts/linux-common/cleanup-rpm-db.sh"
      expect_disconnect = false
    },
    {
      type              = "shell"
      execute_command   = "sudo -E bash '{{ .Path }}'"
      script            = "scripts/linux-sysprep/sysprep-op-ssh-hostkeys.sh"
      expect_disconnect = false
    },
    {
      type              = "shell"
      execute_command   = "sudo -E bash '{{ .Path }}'"
      script            = "scripts/linux-sysprep/sysprep-op-tmp-files.sh"
      expect_disconnect = false
    },
    {
      type              = "shell"
      execute_command   = "sudo -E bash '{{ .Path }}'"
      script            = "scripts/linux-sysprep/sysprep-op-yum-uuid.sh"
      expect_disconnect = false
    },
    {
      type              = "shell"
      execute_command   = "sudo -E bash '{{ .Path }}'"
      script            = "scripts/linux-common/cleanup-disk-space.sh"
      expect_disconnect = false
    },
    {
      type              = "shell"
      execute_command   = "sudo -E bash '{{ .Path }}'"
      script            = "scripts/linux-sysprep/sysprep-op-crash-data.sh"
      expect_disconnect = false
    },
    {
      type              = "shell"
      execute_command   = "sudo -E bash '{{ .Path }}'"
      script            = "scripts/linux-sysprep/sysprep-op-logfiles.sh"
      expect_disconnect = false
    },
    {
      type              = "shell"
      execute_command   = "sudo -E bash '{{ .Path }}'"
      script            = "scripts/linux-sysprep/sysprep-op-bash-history.sh"
      expect_disconnect = false
    },
  ]
}
