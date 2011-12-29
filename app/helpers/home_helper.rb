module HomeHelper
  def follow_suggested_user(user)
    link_to t('follow', :scope => 'users.show'), relationships_path(:id => user),
                                                :remote => true,
                                                :method => :post,
                                                :'data-widget' => 'follow-suggested-user',
                                                :'data-type' => 'html',
                                                :class => 'follow avan-demi'
  end

  def view_more_suggested_users
    link_to t('.view_more'),
            '#',
            :'data-widget' => 'next-suggested-users',
            :class => 'viewmore-btn'
  end

  def pages_count
    (current_user.suggestions_count + (User::SUGGESTED_USERS_PER_PAGE-1)) / User::SUGGESTED_USERS_PER_PAGE
  end
end
