# Loosely based on https://github.com/huit/puppet-pam_access/blob/master/manifests/entry.pp
define pam::access_entry (
  $ensure     = present,
  $permission = '+',
  $user       = false,
  $group      = false,
  $origin     = 'LOCAL'
) {

   # The base class must be included first because it is used by parameter defaults
   # Pattern copied from puppetlabs apache module
   if ! defined(Class['pam']) {
     fail('You must include the pam base class before using any pam defined resources')
   }

  # validate params
  case $permission {
    /^[+-]$/: {
      debug("\$pam::access_entry::permission: ${permission}")
    }
    default: {
      fail("\$pam::access_entry::permission must be '+' or '-'; '${permission}' received")
    }
  }

  if $user {
    $userstr = $group ? {
      true    => "(${user})",
      default => $user
    }
  }
  else {
    $userstr = $group ? {
      true    => "(${title})",
      default => $title
    }
  }

  $context = "/files${::pam::access_conf}/"

  $opposite_permission = $permission ? {
    '+' => '-',
    '-' => '+',
  }

  case $ensure {
    present: {
      # Insert bulk
      augeas { "/files${::pam::access_conf}_${permission}_${userstr}_${origin}_${ensure}_bulk":
        context => $context,
        incl    => "${::pam::access_conf}",
        lens    => 'Access.lns',
        onlyif  => "match access[. = '${permission}'][user = '${userstr}'][origin = '${origin}'] size == 0",
        changes => [
#          "set access[0] ${permission}",
          "defnode myalias access[00] ${permission}",
          "set \$myalias/user '${userstr}'",
          "set \$myalias/origin '${origin}'",
        ],
      }
      case $permission {
        '+': {
          augeas { "/files${::pam::access_conf}_${permission}_${userstr}_${origin}_${ensure}_move":
            context => $context,
            incl    => "${::pam::access_conf}",
            lens    => 'Access.lns',
            onlyif  => "match access[. = '${permission}'][user = '${userstr}'][origin = '${origin}'][preceding-sibling::*[self::access[. = '${opposite_permission}'][user = '${userstr}']]] size > 0",
            changes => [
              "ins access before access[. = '${opposite_permission}'][ user = '${userstr}' ]",
              "defvar new access[. = ''][last()]",
              "mv access[. = '${permission}'][user = '${userstr}'][origin = '${origin}'][last()] \$new",
            ],
            require => Augeas["/files${::pam::access_conf}_${permission}_${userstr}_${origin}_${ensure}_bulk"],
          }
        }
        '-': {
          augeas { "/files${::pam::access_conf}_${permission}_${userstr}_${origin}_${ensure}_move":
            context => $context,
            incl    => "${::pam::access_conf}",
            lens    => 'Access.lns',
            onlyif  => "match access[. = '${permission}'][user = '${userstr}'][origin = '${origin}'][following-sibling::*[self::access[. = '${opposite_permission}'][user = '${userstr}']]] size > 0",
            changes => [
              "ins access after access[. = '${opposite_permission}'][ user = '${userstr}' ][last()]",
              "defvar new access[. = ''][last()]",
              "mv access[. = '${permission}'][user = '${userstr}'][origin = '${origin}'][last()] \$new",
            ],
            require => Augeas["/files${::pam::access_conf}_${permission}_${userstr}_${origin}_${ensure}_bulk"],
          }
        }
        default: {
          fail("Invalid value for permission parameter: ${permission}")
        }
      }
    }
    absent: {
      augeas { "/files${::pam::access_conf}_${permission}_${userstr}_${origin}_${ensure}":
        context => $context,
        incl    => "${::pam::access_conf}",
        lens    => 'Access.lns',
        #TO-DO : tener en cuenta origin
        onlyif  => "match access[. = '${permission}'][user = '${userstr}'][origin = '${origin}'] size > 0",
        changes => "rm access[. = '${permission}'][user = '${userstr}'][origin = '${origin}']",
      }
    }
    default: {
      fail("Unsupported ensure: ${ensure}")
    }
  }

}
