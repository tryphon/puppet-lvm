class lvm::munin::plugins {

  define usage() {
    include munin

    munin::plugin { "lvm_usage_$name":
      source => "puppet:///lvm/munin/lvm_usage_",
      config => "user root"
    }
  }

}
