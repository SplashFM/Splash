require 'acceptance/support/ui/base'

module UI
  module SuggestedSplashers
    def self.included(base)
      base.send(:include, Actions)

      base.before {
        page.extend(Collections)
        page.extend(Matchers)
      }
    end

    module Actions
      def ignore_splasher(position)
        li = 'li:' << case position
                      when :first
                        'first-child'
                      else
                        raise "Unknown suggested splasher position: #{position}"
                      end

        with_suggested_splashers {
          within(li) {
            js = "$(" + w('delete-suggested-user').inspect + ").show()"

            page.execute_script js
            wait_until { find(w('delete-suggested-user')).visible? }
            find(w('delete-suggested-user')).click
          }
        }
      end

      def suggested_splashers(&do_stuff)
        within w('suggested-users'), &do_stuff
      end

      alias_method :with_suggested_splashers, :suggested_splashers

      def view_more_suggested_splashers
        with_suggested_splashers { find(w('next-suggested-users')).click }
      end
    end

    module Collections
    end

    module Matchers
      def has_view_more_button?
        has_css?(w('next-suggested-users'), :visible => true)
      end

      def has_no_view_more_button?
        has_css?(w('next-suggested-users'), :visible => false)
      end
    end
  end
end
