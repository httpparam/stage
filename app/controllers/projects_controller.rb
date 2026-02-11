class ProjectsController < ApplicationController
  before_action :set_event
  before_action :set_project, only: %i[destroy]
  before_action :require_participation
  before_action :require_admin, only: %i[create destroy]

  def create
    @project = @event.projects.build(project_params.merge(user: current_user))

    if @project.save
      redirect_to event_path(@event), notice: "Project added successfully"
    else
      redirect_to event_path(@event), alert: @project.errors.full_messages.to_sentence
    end
  end

  def destroy
    @project.destroy
    redirect_to event_path(@event), notice: "Project removed successfully"
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def set_project
    @project = @event.projects.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:name, :demo_url, :github_url, :description)
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
