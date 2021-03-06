# frozen_string_literal: true

class UsersController < ApplicationController
  # respond_to :html, :json
  # respond_to :html, :xml, :json
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = 'You have created an account!'
      redirect_to @user
    else
      render 'new'
    end
  end

  def show
    @user = User.find(params[:id])
    @my_events = @user.events.paginate(page: params[:page], per_page: 4).order('date DESC')
    @events = []
    @events = User.find(params[:id]).previous_events if params[:passed].present?
    @events = User.find(params[:id]).upcoming_events if params[:coming].present?
    respond_to do |format|
      format.json do
        if request.xhr?
          render :json => {:success => true, :html => (render_to_string("_events", :formats => [:html], :layout => false, :locals => {:events => @events})), data: @events}
        end
      end
 
      format.html {   }
    end
  end

  def invited_events
    @invited_events = Event.where(id: Invitation.all.where(attendee_id: current_user.id,
                                                           accepted: false).pluck(:event_id))
    @accepted_button = true
  end

  private

  def user_params
    params.require(:user).permit(:name, :email)
  end
end
