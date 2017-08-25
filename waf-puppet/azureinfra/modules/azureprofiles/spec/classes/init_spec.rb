require 'spec_helper'
describe 'azureprofiles' do
  context 'with default values for all parameters' do
    it { should contain_class('azureprofiles') }
  end
end
