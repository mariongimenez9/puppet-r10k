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
	$isnt_ca=hiera('profiles::puppetmaster::isnt_ca',true),
	$dns_alt_names=hiera('profiles::puppetmaster::dns_alt_names',puppet),
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
  file { "/etc/puppetlabs/puppetserver/conf.d/webserver.conf":
  	ensure => file,
  	content => template('profile/puppetmaster/webserver.conf.erb'),
	path => '/etc/puppetlabs/puppetserver/conf.d/webserver.conf',
  	}
  file_line { 'disable ca.cfg':
	#ensure => file,
	path => '/etc/puppetlabs/puppetserver/services.d/ca.cfg',
	line => 'puppetlabs.services.ca.certificate-authority-disabled-service/certificate-authority-disabled-service',
	match => '^#puppetlabs.services.ca.certificate-authority-disabled-service/certificate-authority-disabled-service',
	}
  file_line { 'enable ca.cfg':
	#ensure => file,
	path => '/etc/puppetlabs/puppetserver/services.d/ca.cfg',
	line => '#puppetlabs.services.ca.certificate-authority-service/certificate-authority-service',
	match => '^puppetlabs.services.ca.certificate-authority-service/certificate-authority-service',
	}
  ini_setting { "Puppet dns_alt_names":
    ensure  => present,
    path    => '/etc/puppetlabs/puppet/puppet.conf',
    section => 'agent',
    setting => 'dns_alt_names',
    value   => "$dns_alt_names",
    show_diff => true
    }
  }
  else {
  ini_setting { "Puppet dns_alt_names ca":
    ensure  => present,
    path    => '/etc/puppetlabs/puppet/puppet.conf',
    section => 'master',
    setting => 'dns_alt_names',
    value   => "$dns_alt_names",
    show_diff => true
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
