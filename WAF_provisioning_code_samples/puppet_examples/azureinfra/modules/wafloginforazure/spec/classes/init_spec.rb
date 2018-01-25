require 'spec_helper'
describe 'wafloginforazure' do
  context 'with default values for all parameters' do
    it { should contain_class('wafloginforazure') }
  end
end
