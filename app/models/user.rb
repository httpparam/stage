class User < ApplicationRecord
  OTP_EXPIRY_MINUTES = 10

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :age, numericality: { greater_than: 0, less_than: 150 }, allow_nil: true
  validates :first_name, length: { maximum: 50 }, allow_nil: true
  validates :last_name, length: { maximum: 50 }, allow_nil: true
  validate :profile_fields_complete_together

  def profile_fields_complete_together
    if first_name.present? && age.blank?
      errors.add(:age, "is required when first name is provided")
    end
    if age.present? && first_name.blank?
      errors.add(:first_name, "is required when age is provided")
    end
  end

  def full_name
    [ first_name, last_name ].compact_blank.join(" ")
  end

  def display_name
    full_name.present? ? full_name : email.split("@").first
  end

  def self.find_or_create_by_email(email)
    find_or_create_by(email: email.downcase.strip)
  end

  def generate_otp!
    update(otp_secret: ROTP::Base32.random, otp_sent_at: Time.current)
    ROTP::TOTP.new(otp_secret, issuer: "Stage").now
  end

  def verify_otp?(code)
    return false if otp_secret.blank? || otp_expired?

    totp = ROTP::TOTP.new(otp_secret, issuer: "Stage")
    valid = totp.verify(code, drift_behind: OTP_EXPIRY_MINUTES * 60)

    if valid
      update(otp_secret: nil) # Consume OTP after successful verification
      true
    else
      false
    end
  end

  def otp_expired?
    otp_sent_at.blank? || otp_sent_at < OTP_EXPIRY_MINUTES.minutes.ago
  end

  def profile_complete?
    first_name.present? && age.present?
  end

  has_many :events, dependent: :destroy, foreign_key: :user_id
  has_many :projects, dependent: :destroy
  has_many :votes, dependent: :destroy
  has_many :event_participations, class_name: "EventParticipant", dependent: :destroy
  has_many :participated_events, through: :event_participations, source: :event

  def seconds_until_expiry
    return 0 if otp_sent_at.blank?
    expiry_time = otp_sent_at + OTP_EXPIRY_MINUTES.minutes
    [ (expiry_time - Time.current).to_i, 0 ].max
  end
end
