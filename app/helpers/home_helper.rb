module HomeHelper
  def follow_suggested_user(user)
    link_to t('follow', :scope => 'users.show'), relationships_path(:id => user),
                                                :remote => true,
                                                :method => :post,
                                                :'data-widget' => 'follow-suggested-user',
                                                :'data-type' => 'html',
                                                :class => 'follow avan-demi'
  end

  def ignore_user(user)
    link_to '', suggested_splasher_path(user), :method => :delete,
                                              :remote => true,
                                              :'data-widget' => 'delete-suggested-user',
                                              :'data-type' => 'html',
                                              :class => 'delete'
  end

  def view_more_suggested_users
    link_to t('.view_more'), suggested_splashers_path(:page => next_page(pages_count)),
                            :remote => true,
                            :'data-widget' => 'next-suggested-users',
                            :'data-type' => 'html',
                            :class => 'viewmore-btn'
  end

  def pages_count
    (current_user.suggestions_count + (User::SUGGESTED_USERS_PER_PAGE-1)) / User::SUGGESTED_USERS_PER_PAGE
  end
end
