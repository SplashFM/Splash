module Admin::UsersHelper

  def avatar_column(record)
    image_tag record.avatar.url(:thumb)
  end

  def created_at_column record
    record.created_at.strftime "%X %x"
  end

  def confirmed_column(record)
    record.confirmed? ? 'Yes' : 'No'
  end
end
