class Vote < ApplicationRecord
  belongs_to :user
  belongs_to :project

  validates :user, uniqueness: { scope: :project }
  validate :one_vote_per_event

  private

  def one_vote_per_event
    return unless user && project

    existing_vote = user.votes.joins(:project).find_by(project: { event_id: project.event_id })
    if existing_vote && existing_vote != self
      errors.add(:user, "can only vote for one project per event")
    end
  end
end
