require 'spec_helper'
describe 'wafloginforaws' do
  context 'with default values for all parameters' do
    it { should contain_class('wafloginforaws') }
  end
end
