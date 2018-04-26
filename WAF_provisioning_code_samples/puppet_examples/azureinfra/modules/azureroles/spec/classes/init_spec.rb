require 'spec_helper'
describe 'azureroles' do
  context 'with default values for all parameters' do
    it { should contain_class('azureroles') }
  end
end
