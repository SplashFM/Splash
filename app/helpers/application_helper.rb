# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  # Clear both css floats (right and left).
  # use this to
  # (1) ensure that content below gets put BELOW where this call occurs
  # (2) ensure that the height of the containing element extends down far enough to include this call
  def clearboth
    '<div class="clearboth"> </div>'
  end

  # various plugins use different flash attributes... need a way to
  # conglomerate them
  def flash_ok_messages
    join_flash_messages :notice, :success, :info
  end
  def flash_error_messages
    join_flash_messages :error, :failure, :warning, :alert
  end
  def join_flash_messages *messages
    found = []
    for msg in messages
      found << flash[msg] if flash[msg]
    end
    found.join "<br/>  "
  end

  def link_to_next_page(results, text)
    uri  = request.env['PATH_INFO']
    path = ActionController::Routing::Routes.recognize_path(uri)

    unless results.empty?
      link_to(text,
              path.merge!(:page => next_page),
              :remote        => true,
              :'data-widget' => 'next-page',
              :'data-type'   => 'html')
    end
  end

  def link_to_user(user)
    link_to(user.name, user_slug_path(user), :'data-widget' => 'profile-link')
  end
end
