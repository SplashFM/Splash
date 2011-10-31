module SplashesHelper
  def self.dom_id(splash)
    "splash_#{splash.id}"
  end

  def expand_splash(splash)
    link_to(t(".expand"),
            splash_path(splash),
            :remote        => true,
            :'data-type'   => 'html',
            :'data-widget' => 'splash-info-toggle')
  end

  def attribute_splash(splash)
    t('.by', :user => link_to_user(splash.user)).html_safe unless
      splash.owned_by?(current_user)
  end

  def splash_comment_form(splash)
    form = form_for [splash, splash.comments.build],
                :remote => true,
                :html => { :'data-widget'  => 'comment',
                           :'data-type'    => 'html',
                           :'data-result' => "#comments-#{splash.id}"} do |f|

      f.text_area(:body, :size => '30x3') + f.submit
    end

    form
  end
end
