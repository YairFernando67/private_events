class EventsController < ApplicationController
  before_action :find_event, only: %i[show]
  before_action :load_current_user, only: %i[index]

  def index
    @passed_events = Event.all.past
    @coming_events = Event.all.upcoming
    # @events.paginate(page: params[:page], per_page: 5).order('date DESC')
    @from_events_controller = true
  end

  def new
    @event = Event.new
  end

  def create
    @event = current_user.events.build(event_params)
    if @event.save
      flash[:success] = "You have successfuly created a new event!!!"
      redirect_to user_path(current_user)
    else
      render :new
    end
  end

  def invite
    @event = Event.find_by(id: params[:id])
    @invitation = Invitation.new(attendee_id: params[:user_id], event_id: params[:id])

    if @invitation.save
      # byebug
      flash[:success] = "You have successfuly invited a new guest to your event!!!"
      redirect_to current_user
    else
      flash[:danger] = "There was an error trying to add a new guest to your event!!!"
      render event_path(@event)
    end
  end

  def attend
    @invitation = Invitation.find_by(attendee_id: current_user.id, event_id: params[:event_id])
    if @invitation.update(:accepted => true)
      flash[:success] = "You have successfuly accepted the invitation to this event!!!"
      redirect_to current_user
    else
      render event_path(@event)
    end
  end

  def show
  end

  def event_params
    params.require(:event).permit(:location, :date, :description, :name)
  end

  def find_event
    @event = Event.find(params[:id])
  end

  def load_current_user
    User.includes(:attended_events, :invitations, :events) if logged_in?
  end
end
