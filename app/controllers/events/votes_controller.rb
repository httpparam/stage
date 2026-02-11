module Events
  class Admin::VotesController < ApplicationController
    before_action :set_event
    before_action :set_vote, only: [:destroy]
    before_action :require_participation
    before_action :require_admin

    def destroy
      @vote&.destroy
      redirect_to event_path(@event), notice: "Vote revoked successfully"
    end

    def revoke
      vote = @event.votes.joins(:project).find_by(project: { id: params[:id] }, user_id: params[:user_id])
      vote&.destroy
      redirect_to event_path(@event), notice: "Vote revoked successfully"
    end

    private

    def set_event
      @event = Event.find(params[:event_id])
    end

    def set_vote
      @vote = @event.votes.find(params[:id])
    end

    def require_participation
      unless @event.participant?(current_user)
        redirect_to events_path, alert: "You must join this event first"
      end
    end

    def require_admin
      unless @event.admin?(current_user)
        redirect_to event_path(@event), alert: "You don't have permission to do that"
      end
    end
  end
end
