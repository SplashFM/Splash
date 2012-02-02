module SplashesHelper
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
