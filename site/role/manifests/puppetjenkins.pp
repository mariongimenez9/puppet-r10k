# == Class: role:puppetreports
# Include profiles for a puppetreports role
#

class role::puppetjenkins {
  include ::profile::base
  include ::profile::puppetagent
  include jenkins
}
