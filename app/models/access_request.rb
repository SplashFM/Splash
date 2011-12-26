class AccessRequest < ActiveRecord::Base
  ACCESS_CODES_PATH = File.join(Rails.root, %w(config access_codes.yml))

  validates :email,
            :presence   => true,
            :uniqueness => true,
            :format     => {:with => /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i}

  before_create :reset_granted
  before_create :generate_referral_code
  after_create  :confirm_inclusion

  scope :requested_on, lambda { |date| where('date(created_at) = ?', date) }
  scope :pending, where(:granted => false)

  def self.codes
    @codes ||= YAML.load_file(ACCESS_CODES_PATH)
  end

  def as_json(options = {})
    super.merge!(:referral_url => options[:url_builder].call(referral_code))
  end

  def code
    self.class.codes.first
  end

  def invite(code)
    UserMailer.delay.invite self, code

    mark_invited
  end

  private

  def confirm_inclusion
    UserMailer.delay.confirm_access_request self
  end

  def generate_referral_code
    self.referral_code = rand(36**8).to_s(36)
  end

  def mark_invited
    update_attribute :granted, true
  end

  def reset_granted
    self.granted = false

    nil
  end
end
