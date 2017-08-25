module PuppetX
  module PuppetLabs
    module Azure
      module Property
        class PositiveInteger < Puppet::Property
          def insync?(is)
            is.to_i == should.to_i
          end
          validate do |value|
            fail "#{self.name.to_s} should be an Integer" unless value.to_i.to_s == value.to_s
            fail "#{self.name.to_s} should be greater than 0" unless value.to_i > 0
          end
        end
      end
    end
  end
end
