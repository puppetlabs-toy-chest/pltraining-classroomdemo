# REPLACE yourname, yourkeypair, and the aws_region with your info!!
class { 'classroomdemo::aws':
     creator => 'yourname',
     key_pair => 'yourkeypair',
     ensure      => present,
     pe_version  => '2016.2.1',
     pe_username => 'admin',
     pe_password => 'puppetlabs',
     aws_region  => 'us-west-2',
}
