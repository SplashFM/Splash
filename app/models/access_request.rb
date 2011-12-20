class AccessRequest < ActiveRecord::Base
  ACCESS_CODES_PATH = File.join(Rails.root, %w(config access_codes.yml))

  validates :email, :presence => true, :uniqueness => true

  before_create :reset_granted

  def self.codes
    @codes ||= YAML.load_file(ACCESS_CODES_PATH)
  end

  private

  def reset_granted
    self.granted = false

    nil
  end
end
