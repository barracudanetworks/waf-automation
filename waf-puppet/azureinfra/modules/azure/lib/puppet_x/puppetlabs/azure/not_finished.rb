module PuppetX
  module Puppetlabs
    module Azure
      # This exception is used to signal expected continuations when waiting for events in the cloud
      class NotFinished < RuntimeError
      end
    end
  end
end
