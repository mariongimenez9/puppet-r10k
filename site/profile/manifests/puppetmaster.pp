# == Class: profiles::puppetmaster
#
#  Install and configure puppetmaster with remote puppetdb
#
# === Parameters
#
# [*use_puppetdb*]
#
# Install puppetdb on the master node?
# Default value is looked up in hiera and set as "false" if nothing is found
#
# === Examples
#
#  class { 'profiles::puppetmaster':
#    user_puppetdb  => true
#  }
#
# === Authors
#
# Laurent Bernaille
#
# === Copyright
#
# Copyright 2013 Your name here, unless otherwise noted.
#

class profile::puppetmaster(
    $use_puppetdb=hiera('profiles::puppetmaster::use_puppetdb',false),
	$use_puppetca=hiera('profiles::puppetmaster::$isnt_ca',true),
) {

  class { 'puppetserver':
    config => {
      'java_args'     => {
        'xms'   => '512m',
        'xmx'   => '512m'
      }
    }
  }
  contain 'puppetserver'
  # Ensure server starts before agent to avoid key issues
  # Service['puppetserver']->Service['puppet']
  
  if $isnt_ca {
  #file { "/etc/puppetlabs/puppetserver/services.d/ca.cfg":
  #	ensure => file,
  #	content => epp('profile/puppetmaster/ca.cfg.epp',{ 'ca' => hiera('profiles::puppetmaster::ca',[])}),
  #	}
  #file { "/etc/puppetlabs/puppetserver/conf.d/webserver.conf":
  #	ensure => file,
  #	content => epp('profile/puppetmaster/webserver.conf.epp',{ 'webserver' => hiera('profiles::puppetmaster::webserver',[])}),
  #	}
  file_line { 'ca.cfg':
	ensure => file,
	path => '/etc/puppetlabs/puppetserver/services.d/ca.cfg',
	line => '#puppetlabs.services.ca.certificate-authority-disabled-service/certificate-authority-disabled-service',
	match => '^#puppetlabs.services.ca.certificate-authority-disabled-service/certificate-authority-disabled-service',
	}
  file_line { 'ca.cfg':
	ensure => file,
	path => '/etc/puppetlabs/puppetserver/services.d/ca.cfg',
	line => '#puppetlabs.services.ca.certificate-authority-service/certificate-authority-service',
	match => '^puppetlabs.services.ca.certificate-authority-service/certificate-authority-service',
	}
  file_line { 'webserver.conf':
	ensure => file,
	path => '/etc/puppetlabs/puppetserver/conf.d/webserver.conf',
	line => 'ssl-cert: /etc/puppetlabs/puppet/ssl/certs/puppetmaster2.vm.local.pem',
	}
  file_line { 'webserver.conf':
	ensure => file,
	path => '/etc/puppetlabs/puppetserver/conf.d/webserver.conf',
	line => 'ssl-key: /etc/puppetlabs/puppet/ssl/private_keys/puppetmaster2.vm.local.pem',
	}
  file_line { 'webserver.conf':
	ensure => file,
	path => '/etc/puppetlabs/puppetserver/conf.d/webserver.conf',
	line => 'ssl-ca-cert: /etc/puppetlabs/puppet/ssl/certs/ca.pem',
	}
  }

  $confdir = $::settings::confdir
  file { "${confdir}/autosign.conf":
    ensure  => file,
    content => epp('profile/puppetmaster/autosign.conf.epp',{ 'autosign_hosts' => hiera('profiles::puppetmaster::autosign_hosts',[])}),
  }

  class { '::puppetserver::hiera::eyaml':
    require => Class['puppetserver::install'],
  }
  contain '::puppetserver::hiera::eyaml'

  if $use_puppetdb {

    class { 'puppetdb::master::config':
      puppetdb_server             => hiera('puppetdb_host'),
      manage_routes               => true,
      manage_storeconfigs         => true,
      manage_report_processor     => true,
      enable_reports              => true,
      strict_validation           => false,
      puppetdb_soft_write_failure => true
    }
    contain 'puppetdb::master::config'

  }
}
