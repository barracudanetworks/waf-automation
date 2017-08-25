require 'spec_helper'
describe 'azurecudawafconfig' do
  context 'with default values for all parameters' do
    it { should contain_class('azurecudawafconfig') }
  end
end
