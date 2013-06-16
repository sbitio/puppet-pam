define pam::service_conf (
  $ensure = present,
  $service = $title,
  $type,
  $control,
  $module
) {

  Class['pam'] -> Pam::Service_conf <| |>

# augtool> ins /files/etc/pam.d/sshd/999 after /files/etc/pam.d/sshd/last
# augtool> set /files/etc/pam.d/sshd/999/type account
# augtool> set /files/etc/pam.d/sshd/999/control required
# augtool> set /files/etc/pam.d/sshd/999/module pam_access.so
# augtool> match /files/etc/pam.d/sshd/*[type = 'account'][module = 'pam_access.so']

  case $ensure {
    present: {
      augeas { "${pam::params::conf_d_path}/${service}_${type}_${control}_${module}_${ensure}":
        context => "/files${pam::params::conf_d_path}/${service}/",
        # TO-DO: ¿Better performance with lens defined? "augtool ls /augeas/files/etc/pam.d/sshd"
        incl    => "${pam::params::conf_d_path}/${service}",
        lens    => 'Pam.lns',
        onlyif  => "match *[type = '${type}'][control = '${control}'][module = '${module}'] size == 0",
        changes => [
          "ins 99999 after *[last()]",
          "set 99999/type ${type}",
          "set 99999/control ${control}",
          "set 99999/module ${module}",
          "set 99999/#comment 'WARNING: Puppet managed line'",
        ],
      }
    }
    absent: {
      augeas { "${pam::params::conf_d_path}/${service}_${type}_${control}_${module}_${ensure}":
        context => "/files${pam::params::conf_d_path}/${service}/",
        # TO-DO: ¿Better performance with lens defined? "augtool ls /augeas/files/etc/pam.d/sshd"
        incl    => "${pam::params::conf_d_path}/${service}",
        lens    => 'Pam.lns',
        onlyif  => "match *[type = '${type}'][control = '${control}'][module = '${module}'] size > 0",
        changes => "rm *[type = '${type}'][control = '${control}'][module = '${module}']",
      }
    }
    default: {
      fail("Unsupported ensure: ${ensure}")
    }
  }

}
