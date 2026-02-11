class Event < ApplicationRecord
  belongs_to :user, class_name: "User"
  has_many :projects, dependent: :destroy
  has_many :event_participants, dependent: :destroy
  has_many :participants, through: :event_participants, source: :user

  validates :name, presence: true
  validates :invite_code, presence: true, uniqueness: true
  validates :event_date, presence: true

  before_validation :generate_invite_code, on: :create

  def admin?(user)
    event_participants.find_by(user: user)&.is_admin? || user == self.user
  end

  def participant?(user)
    event_participants.exists?(user: user)
  end

  def add_participant(user, is_admin: false)
    event_participants.create!(user: user, is_admin: is_admin)
  end

  def remove_participant(user)
    participant = event_participants.find_by(user: user)
    participant&.destroy
  end

  def vote_count
    projects.joins(:votes).count
  end

  private

  def generate_invite_code
    return if invite_code.present?
    self.invite_code = loop do
      code = SecureRandom.alphanumeric(8).upcase
      break code unless Event.exists?(invite_code: code)
    end
  end
end
