# == Class: profile::puppetjenkins
#
#  Install and configure pupptjenkins
#
# === Parameters
#
# === Authors
#
# Laurent Bernaille
#
# === Copyright
#
# Copyright 2013 Your name here, unless otherwise noted.
#

class profile::puppetjenkins(
) {

  class { 'jenkins':
 }
  
  jenkins::user { 'test':
	password => 'test'
  }

  jenkins::plugin { 'gitlab': }
  jenkins::plugin { 'gitlab-hook': }
  
}
