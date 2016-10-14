# == Class: profiles::puppetagent
#
#  Install and configure puppetagent
#
# === Authors
#
# Laurent Bernaille
#
# === Copyright
#
# Copyright 2013 Your name here, unless otherwise noted.
#

class profile::puppetagent(
    $puppetmaster=hiera('puppet_server','puppet'),
    $puppet_ca_server=hiera('puppet_ca_server','puppet'),
) {

  filebucket { 'puppetmaster':
    path  => false
  }

  File {
  # All file resources will be backed up
    backup  => 'puppetmaster',
  }

  ini_setting { "Puppet server":
    ensure  => present,
    path    => '/etc/puppetlabs/puppet/puppet.conf',
    section => 'agent',
    setting => 'server',
    value   => "$puppetmaster",
    show_diff => true
  }

  ini_setting { "Puppet server":
    ensure  => present,
    path    => '/etc/puppetlabs/puppet/puppet.conf',
    section => 'agent',
    setting => 'ca_server',
    value   => "$puppet_ca_server",
    show_diff => true
  }
  
  service { 'puppet':
    ensure => running,
    enable => true  
  }
}
