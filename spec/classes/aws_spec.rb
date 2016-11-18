require "spec_helper"

describe "classroomdemo::aws" do
  let(:node) { 'test.example.com' }

  let(:params) { {
    :creator  => 'test',
    :key_pair => 'test',
  } }

  it { is_expected.to compile.with_all_deps }

end
