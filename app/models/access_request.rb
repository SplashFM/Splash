class AccessRequest < ActiveRecord::Base
  validates :email, :presence => true, :uniqueness => true

  before_create :reset_granted

  private

  def reset_granted
    self.granted = false

    nil
  end
end
