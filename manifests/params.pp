class pam::params (
  $conf_d_path = hiera('conf_d_path', '/etc/pam.d'),
  $access_conf = hiera('access_conf', '/etc/security/access.conf')
) {
  case $::operatingsystem {
    ubuntu, debian: {

    }
#    redhat, centos: {
#    }
    default: {
      fail("Unsupported platform: ${::operatingsystem}")
    }
  }
}
