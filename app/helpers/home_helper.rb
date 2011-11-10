module HomeHelper
  def follow_suggested_user(user)
    link_to t('follow', :scope => 'users.show'), relationships_path(:id => user),
                                                :remote => true,
                                                :method => :post,
                                                :'data-widget' => 'follow-suggested-user',
                                                :'data-type' => 'html',
                                                :class => 'follow avan-demi'
  end
end
