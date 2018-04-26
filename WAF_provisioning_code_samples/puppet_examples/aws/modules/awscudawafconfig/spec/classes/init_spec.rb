require 'spec_helper'
describe 'wafconfig' do
  context 'with default values for all parameters' do
    it { should contain_class('wafconfig') }
  end
end
