module UI
  module Actions
    def self.included(base)
      base.let(:user) { create(User).with_required_info! }
    end

    def login(user)
      visit new_user_session_path

      fill_in "user_email", :with => user.email
      wait_until{ page.has_content?('Password') }
      fill_in "user_password", :with => user.password
      click_button t('devise.buttons.login')
    end

    def search_for(filter, search_type, &block)
      within(search_form(search_type)) { fill_in "f", :with => filter }

      within(search_results(search_type), &block) if block_given?
    end

    def splash(track)
      within(track_css(track)) { find(splash_css).click }
    end

    def upload(path)
      t = build!(Track)

      click_link t('formtastic.actions.upload')

      wait_until { page.has_css?(upload_css, :visible => true) }

      fill_in Track.human_attribute_name(:title), :with => t.title
      fill_in Track.human_attribute_name(:artist), :with => t.artist
      attach_file Track.human_attribute_name(:data), path
    end
  end
end
