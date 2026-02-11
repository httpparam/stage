class Project < ApplicationRecord
  belongs_to :event
  belongs_to :user, class_name: "User"
  has_many :votes, dependent: :destroy

  validates :name, presence: true
  validates :event, presence: true

  def vote_count
    votes.count
  end

  def voted_by?(user)
    votes.exists?(user: user)
  end
end
