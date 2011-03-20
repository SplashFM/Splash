class Visitor < User
  after_initialize :set_default_attributes

  def active?
    false # Disable sign-in for visitors
  end

  private

  def set_default_attributes
    self.password = self.password_confirmation = 'secret'
  end
end
