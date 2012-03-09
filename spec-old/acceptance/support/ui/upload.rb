require 'acceptance/support/ui/base'
require 'acceptance/support/ui/splash'

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
      include Splash::Actions

      def splash_uploaded
        click_button t("upload.splash")
      end

      def upload(path, track = nil, comment = nil)
        upload_song(path, comment)

        wait_until { page.has_metadata_form? }

        if track
          fill_in 'title',      :with => track.title
          fill_in 'performers', :with => track.performers.first
          fill_in 'albums',     :with => track.albums.try(:first)
        end

        click_button t('upload.save')
      end

      def upload_song(path, comment = nil)
        click_link t('upload.upload')
        wait_until { page.has_visible_upload_form? }

        add_splash_comment comment if comment
        attach_file 'data', path
      end
    end

    module Collections
    end

    module Matchers
      def has_metadata_form?
        has_css?(w('metadata'))
      end

      def has_visible_upload_form?
        has_css?(".uploadForm", :visible => true)
      end
    end
  end
end
