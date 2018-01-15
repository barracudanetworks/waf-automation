require 'spec_helper'
describe 'vrs' do
  context 'with default values for all parameters' do
    it { should contain_class('vrs') }
  end
end
