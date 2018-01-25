require 'spec_helper'
describe 'vrsinazure' do
  context 'with default values for all parameters' do
    it { should contain_class('vrsinazure') }
  end
end
