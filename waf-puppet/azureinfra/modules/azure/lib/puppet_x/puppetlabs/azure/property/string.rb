module PuppetX
  module PuppetLabs
    module Azure
      module Property
        class String < Puppet::Property
          validate do |value|
            fail "#{self.name.to_s} should be a String" unless value.is_a? ::String
          end
        end
      end
    end
  end
end
