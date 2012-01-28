class AccessRequest < ActiveRecord::Base
  ADMIN_KEY         = '23ef4tt33'
  INVITATION_COUNT  = 4
  ACCESS_CODES_PATH = File.join(Rails.root, %w(config access_codes.yml))

  belongs_to :inviter, :class_name => 'User'

  validates :email,
            :presence   => true,
            :uniqueness => true,
            :format     => {:with => /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i},
            :unless     => :uid?
  validates :uid,
            :presence   => true,
            :uniqueness => {:scope => :provider},
            :unless     => :email?

  before_create :reset_granted
  before_create :generate_code
  before_create :generate_referral_code
  before_create :mark_invited, :if => :inviter
  after_create  :notify, :if => :email?

  validate :ensure_invites_available, :if => :inviter

  scope :requested_on, lambda { |date| where('date(created_at) = ?', date) }
  scope :pending, where(:granted => false)

  def self.email(date)
    requests = requested_on(date).pending

    AdminMailer.list_access_requests(requests).deliver if requests.present?
  end

  def self.codes
    @codes ||= YAML.load_file(ACCESS_CODES_PATH)
  end

  def self.code?(code)
    codes.include?(code) || find_by_code_and_user_id(code, nil)
  end

  def self.remaining(user)
    INVITATION_COUNT - where(:inviter_id => user.id).count
  end

  def self.reserve(code, user)
    # no access request will be returned for generic codes
    find_by_code(code).try :update_attribute, :user_id, user.id
  end

  def as_json(options = {})
    hash = super
    hash[:referral_url] = options[:url_builder].call(referral_code) if options[:url_builder].present?
    hash[:remaining_count] = AccessRequest.remaining(inviter) if inviter
    hash
  end

  def invite(email=nil)
    transaction {
      mark_invited
      save!

      UserMailer.delay.invite self, code
    }
  end

  private
  def ensure_invites_available
    unless self.class.remaining(inviter) > 0
      errors.add(:inviter, 'has no invites left')
    end
  end

  def notify
    mailer = inviter ? 'send_invitation' : 'confirm_access_request'

    UserMailer.delay.send(mailer, self)
  end

  def generate_code
    self.code = rand(36**8).to_s(36)
  end

  def generate_referral_code
    self.referral_code = rand(36**8).to_s(36)
  end

  def mark_invited
    self.granted = true
  end

  def reset_granted
    self.granted = false

    nil
  end
end
