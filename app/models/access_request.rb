class AccessRequest < ActiveRecord::Base
  ACCESS_CODES_PATH = File.join(Rails.root, %w(config access_codes.yml))

  validates :email, :presence => true, :uniqueness => true

  before_create :reset_granted

  scope :requested_on, lambda { |date| where('date(created_at) = ?', date) }
  scope :pending, where(:granted => false)

  def self.codes
    @codes ||= YAML.load_file(ACCESS_CODES_PATH)
  end

  def code
    self.class.codes.first
  end

  def invite
    UserMailer.delay.invite self

    mark_invited
  end

  private

  def mark_invited
    update_attribute :granted, true
  end

  def reset_granted
    self.granted = false

    nil
  end
end
