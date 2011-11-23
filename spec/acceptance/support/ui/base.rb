module UI
  module Base
    def self.included(base)
      base.send(:include, Actions)
      base.send(:include, Helpers)
    end

    module Actions
      def click_widget(widget)
        find(w(widget)).click
      end

      def fast_login(*args)
        email, pwd = *case args.size
                      when 1
                       [args.first.email, args.first.password]
                      else
                        args
                      end

        visit new_user_session_path

        page.execute_script <<-JS
          $.ajax(
            "#{user_session_path}",
            {type: "POST",
             async: false,
             cache: false,
             data:  {"user[email]": "#{email}",
                     "user[password]": "#{pwd}"}});
        JS

        visit dashboard_path
      end

      def go_to(section, full_load = false)
        if full_load
          case section
          when 'home'
            visit root_path
          else
            raise "Unknown section: #{section}"
          end
        else
          click_link t("simple_navigation.menus.#{section}")
        end
      end

      def log_out
        with_lifesaver { click_link t('lifesaver.logout') }
      end

      def with_lifesaver(&do_stuff)
        click_widget 'lifesaver'
        within w('lifesaver-menu'), &do_stuff
      end
    end

    module Helpers
      def t(*args)
        klass, field = args

        case klass
        when Class
          klass.human_attribute_name(field)
        else
          I18n.t(*args)
        end
      end

      def w(name)
        "[data-widget = '#{name}']"
      end
    end

    module Matchers
      def home?
        %w(/ /home /dashboard).include?(current_path)
      end

      Capybara::Session.send(:include, self)
    end
  end
end
