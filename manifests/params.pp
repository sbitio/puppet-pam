# pam::params
#
# This class hanfles the module data
#
class pam::params (
  $conf_d_path = '/etc/pam.d',
  $access_conf = '/etc/security/access.conf',
) {
  case $::operatingsystem {
    ubuntu, debian: { }
    redhat, centos: { }
    default: {
      fail("Unsupported platform: ${::operatingsystem}")
    }
  }
}
