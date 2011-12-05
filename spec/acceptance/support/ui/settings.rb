module UI
  module Settings
    def self.included(base)
      base.send(:include, Actions)
    end

    module Actions
      def edit_settings(&actions)
        with_settings {
          actions.call
          click_button t('registrations.edit.save')
        }
      end

      def with_settings(&do_stuff)
        with_lifesaver { click_link t('lifesaver.settings') }

        within w('settings'), &do_stuff
      end
    end
  end
end
