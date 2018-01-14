require 'spec_helper'
describe 'profiles' do
  context 'with default values for all parameters' do
    it { should contain_class('profiles') }
  end
end
