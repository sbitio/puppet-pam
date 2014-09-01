class pam::sshd (
  $ensure       = present,
  $protect_root = true,
) {
  require ::pam

  pam::service_conf { 'sshd':
    ensure  => $ensure,
    type    => 'account',
    control => 'required',
    module  => 'pam_access.so',
  }

  if $protect_root {
    pam::access_entry { 'root-allow-local':
      ensure     => $ensure,
      permission => '+',
      user       => 'root',
      origin     => 'LOCAL',
    }
    pam::access_entry { 'root-disallow-rest':
      ensure     => $ensure,
      permission => '-',
      user       => 'root',
      origin     => 'ALL',
    }
  }
} 
}
