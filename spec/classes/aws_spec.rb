require "spec_helper"

describe "classroomdemo::aws" do
  let(:node) { 'test.example.com' }

  let(:params) { {
    :creator  => 'test',
    :key_pair => 'test',
  } }

  it { is_expected.to compile.with_all_deps }

  it do
    is_expected.to contain_ec2_securitygroup("test-sg")
      .with({
        'ensure' => 'present',
        'region' => 'us-west-2',
        'description' => 'Security group for VPC',
        'ingress' => [{
          'protocol' => 'tcp',
          'port'     => '22',
          'cidr'     => '0.0.0.0/0'
          },{
          'protocol' => 'tcp',
          'port'     => '443',
          'cidr'     => '0.0.0.0/0'
        }]
      })
  end

  it do
    is_expected.to contain_ec2_instance("test-puppet-master")
      .with({
        'ensure'                      => 'present',
        'associate_public_ip_address' => true,
        'region'                      => 'us-west-2',
        'image_id'                    => 'ami-e08efbd0',
        'instance_type'               => 'm3.medium',
        'key_name'                    => 'test',
        'security_groups'             => ['test-sg'],
        'monitoring'                  => true,
      })
  end

end
