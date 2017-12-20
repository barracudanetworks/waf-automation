Puppet::Type.newtype(:webapp_create) do
    @doc = "Creates a scan"

    ensurable

    newparam(:name, :namevar => true) do
    desc "Name"
    validate do |value|
      fail("Invalid name #{value}, Illegal characters present") unless value =~ /^[a-zA-Z][a-zA-Z0-9\._:\-]*$/
    end
    end

    newproperty(:url) do
      desc "web application url"
    end 

    newproperty(:waf_serial) do
      desc "serial number of the waf system"
    end 

    newproperty(:waf_service) do
      desc "waf service"
    end 

    newproperty(:waf_policy_name) do
      desc "waf policy name"
    end    
    newproperty(:verify_email) do
      desc "Test URL"
    end 

    newparam(:verify_method) do
      desc "Email address to verify the scan"
    end

    newparam(:verification_email) do
      desc "Test value"
    end 

    newparam(:notification_emails) do
      desc "Test value"
    end 

end
