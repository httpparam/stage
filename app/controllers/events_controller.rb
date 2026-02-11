class EventsController < ApplicationController
  before_action :set_event, only: %i[show edit update destroy join]
  before_action :require_participation, only: %i[show]
  before_action :require_admin, only: %i[edit update destroy]

  def index
    @events = Event.all
    @user_events = current_user.events
    @participated_events = current_user.participated_events
  end

  def show
    @projects = @event.projects.includes(:user, :votes)
    @user_vote = current_user.votes.find_by(project: @event.projects)
  end

  def new
    @event = Event.new
  end

  def create
    @event = current_user.events.build(event_params)

    if @event.save
      @event.add_participant(current_user, is_admin: true)
      redirect_to event_path(@event), notice: "Event created successfully! Share code: #{@event.invite_code}"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @event.update(event_params)
      redirect_to event_path(@event), notice: "Event updated successfully"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @event.destroy
    redirect_to events_path, notice: "Event deleted successfully"
  end

  def join
    if @event.participant?(current_user)
      redirect_to events_path, alert: "You have already joined this event"
      return
    end

    @event.add_participant(current_user)
    redirect_to event_path(@event), notice: "Successfully joined the event"
  end

  def leave
    if @event.user == current_user
      redirect_to event_path(@event), alert: "Event creator cannot leave. Delete the event instead."
      return
    end

    @event.remove_participant(current_user)
    redirect_to events_path, notice: "You have left the event"
  end

  private

  def set_event
    @event = Event.find_by(invite_code: params[:id]) || Event.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:name, :description, :event_date)
  end

  def require_participation
    unless @event.participant?(current_user)
      redirect_to events_path, alert: "You must join this event to view it"
    end
  end

  def require_admin
    unless @event.admin?(current_user)
      redirect_to event_path(@event), alert: "You don't have permission to do that"
    end
  end
end
