require 'acceptance/support/ui/base'

module UI
  module Upload
    def self.included(base)
      base.send(:include, Actions)

      base.before {
        page.extend(Collections)
        page.extend(Matchers)
      }
    end

    module Actions
    end

    module Collections
    end

    module Matchers
    end
  end
end
