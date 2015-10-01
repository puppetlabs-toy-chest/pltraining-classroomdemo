class classroomdemo::aws (
  $creator,
  $key_pair,
  $ensure      = present,
  $pe_version  = '2015.2.0',
  $pe_username = 'admin',
  $pe_password = 'puppetlabs',
  $aws_region  = 'us-west-2',
) {

  # Set up the VPC and network
  ec2_vpc { "${creator}-vpc":
    ensure       => $ensure,
    region       => $aws_region,
    cidr_block   => '10.0.0.0/16',
  }

  ec2_vpc_subnet { "${creator}-subnet":
    ensure            => $ensure,
    region            => $aws_region,
    vpc               => "${creator}-vpc",
    cidr_block        => '10.0.0.0/24',
    route_table       => "${creator}-routes",
  }

  ec2_vpc_internet_gateway { "${creator}-igw":
    ensure => $ensure,
    region => $aws_region,
    vpc    => "${creator}-vpc",
  }

  ec2_vpc_routetable { "${creator}-routes":
    ensure => $ensure,
    region => $aws_region,
    vpc    => "${creator}-vpc",
    routes => [
      {
        destination_cidr_block => '10.0.0.0/16',
        gateway                => 'local'
        },{
          destination_cidr_block => '0.0.0.0/0',
          gateway                => "${creator}-igw"
        },
    ],
  }


  # Security group (autorequires vpc as needed)
  ec2_securitygroup { "${creator}-sg":
    ensure      => $ensure,
    region      => $aws_region,
    vpc         => "${creator}-vpc",
    description => 'Security group for VPC',
    ingress     => [{
      protocol => 'tcp',
      port     => 22,
      cidr     => '0.0.0.0/0'
      },{
        protocol => 'tcp',
        port     => 443,
        cidr     => '0.0.0.0/0'
      }]
  }


  # Set up the Puppet Master instance (autorequires security group and subjet as needed)
  ec2_instance { "${creator}-puppet-master":
    ensure                      => $ensure,
    associate_public_ip_address => true,
    region                      => $aws_region,
    image_id                    => 'ami-e08efbd0',
    instance_type               => 'm3.medium',
    key_name                    => $key_pair,
    security_groups             => ["${creator}-sg"],
    subnet                      => "${creator}-subnet",
    monitoring                  => 'true',
    user_data                   => template("${module_name}/aws/master-pe-userdata.erb"),
  }

  case $ensure {
    present: {
      # noop, the module autorequires dependencies properly for creation
    }
    absent: {
      Ec2_instance["${creator}-puppet-master"]   -> Ec2_securitygroup["${creator}-sg"]
      Ec2_instance["${creator}-puppet-master"]   -> Ec2_vpc_subnet["${creator}-subnet"]
      Ec2_securitygroup["${creator}-sg"]         -> Ec2_vpc["${creator}-vpc"]
      Ec2_vpc_subnet["${creator}-subnet"]        -> Ec2_vpc["${creator}-vpc"]
      Ec2_vpc_subnet["${creator}-subnet"]        -> Ec2_vpc_routetable["${creator}-routes"]
      Ec2_vpc_routetable["${creator}-routes"]    -> Ec2_vpc_internet_gateway["${creator}-igw"]
      Ec2_vpc_routetable["${creator}-routes"]    -> Ec2_vpc["${creator}-vpc"]
      Ec2_vpc_internet_gateway["${creator}-igw"] -> Ec2_vpc["${creator}-vpc"]
    }
    default: {
      fail("Ensure must be one of absent, present. Got ${ensure}.")
    }

  }

}
