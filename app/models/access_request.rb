class AccessRequest < ActiveRecord::Base
  ADMIN_KEY         = '23ef4tt33'
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

  def self.reserve(code, user)
    # no access request will be returned for generic codes
    find_by_code(code).try :update_attribute, :user_id, user.id
  end

  def as_json(options = {})
    super.merge!(:referral_url => options[:url_builder].call(referral_code))
  end

  def invite
    transaction {
      generate_code
      mark_invited
      save!

      UserMailer.delay.invite self, code
    }
  end

  private

  def confirm_inclusion
    UserMailer.delay.confirm_access_request self
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
