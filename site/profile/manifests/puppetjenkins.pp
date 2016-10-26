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
	email => test@test.local,
	password => 'test',
  }

  jenkins::plugin { 'gitlab-plugin': }
  jenkins::plugin { 'gitlab-hook-plugin': }
  
}
