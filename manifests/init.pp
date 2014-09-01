class pam (
  $autload     = true,
  $autorealize = true,
) inherits pam::params {

  validate_bool($autoload)
  validate_bool($autorealize)

  if $autoload {
    # service_confs
    $pam_service_conf_defaults = hiera('pam::service_conf::defaults', {})
    $pam_service_confs         = hiera('pam::service_confs', {})
    create_resources('::pam::service_conf', $pam_service_confs, $pam_service_conf_defaults)
    # access_entries
    $pam_access_entry_defaults = hiera('pam::access_entry::defaults', {})
    $pam_access_entries        = hiera('pam::access_entries', {})
    create_resources('::pam::access_entry', $pam_access_entries, $pam_access_entry_defaults)
  }

  if $autorealize {
    Pam::Service_conf <| |>
    Pam::Service_conf <<| tag == $::fqdn |>>
    Pam::Access_entry <| |>
    Pam::Access_entry <<| tag == $::fqdn |>>
  }
}
