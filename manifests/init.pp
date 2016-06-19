class lvm {
  package { 'lvm2': }

  file { '/usr/local/sbin/lvcreate-fs':
    source => 'puppet:///modules/lvm/lvcreate-fs',
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
      exec {"create-mount-point-by-label-$name":
        command => "mkdir -p ${name}",
        creates => $name,
        before => Mount[$name]
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
        # ext labels are limited to 16 characters
        label => regsubst($name,'^(.{16}).*','\1'),
        require => Lvm::Logical_Volume[$name]
      }
    }
  }
}

class lvm::munin::plugins {

  define usage() {
    include munin

    munin::plugin { "lvm_usage_$name":
      source => "puppet:///modules/lvm/munin/lvm_usage_",
      config => "user root"
    }
  }

}
