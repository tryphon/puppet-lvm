class lvm {
  package { 'lvm2': }

  file { '/usr/local/sbin/lvcreate-fs':
    source => 'puppet:///lvm/lvcreate-fs',
    mode => 755
  }

  define logical_volume($size) {
    exec { "lvcreate /dev/vg/$name":
      command => "lvcreate-fs $name $size",
      creates => "/dev/vg/$name",
      require => File['/usr/local/sbin/lvcreate-fs']
    }
  }

  class volume {
    define mount_by_label($label) {
      if ! defined(File[$name]) {
        file { $name: ensure => directory }
      }
      mount { $name:
        ensure => mounted,
        device => "LABEL=$label",
        fstype => 'ext4',
        options => 'defaults'
      }
    }

    define local($mount_point = "/srv/$name", $size) {
      lvm::logical_volume { $name: size => $size }
      lvm::volume::mount_by_label { $mount_point:
        label => $name,
        require => Lvm::Logical_Volume[$name]
      }
    }
  }
}

class lvm::munin::plugins {

  define usage() {
    include munin

    munin::plugin { "lvm_usage_$name":
      source => "puppet:///lvm/munin/lvm_usage_",
      config => "user root"
    }
  }

}
