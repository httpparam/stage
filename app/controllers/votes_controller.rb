class VotesController < ApplicationController
  before_action :set_event_and_project
  before_action :require_participation

  def create
    @vote = @project.votes.find_or_initialize_by(user: current_user)

    if @vote.save
      redirect_to event_path(@event), notice: "Vote recorded successfully"
    else
      redirect_to event_path(@event), alert: @vote.errors.full_messages.to_sentence
    end
  end

  def destroy
    @vote = @project.votes.find_by(user: current_user)
    @vote&.destroy
    redirect_to event_path(@event), notice: "Vote removed"
  end

  private

  def set_event_and_project
    @event = Event.find(params[:event_id])
    @project = @event.projects.find(params[:project_id])
  end

  def require_participation
    unless @event.participant?(current_user)
      redirect_to events_path, alert: "You must join this event to vote"
    end
  end
end
