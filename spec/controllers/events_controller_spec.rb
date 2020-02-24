# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventsController, type: :controller do
  fixtures :users
  fixtures :events

  # before(:each) do
  #   @user = users(:yair)
  # end

  # after(:each) do
  #   @user.destroy
  # end

  it "get '/events' should render template INDEX" do
    get :index
    expect(response).to render_template('events/index')
  end
  
  it "get '/events/new' should render template NEW" do
    get :new
    expect(response).to render_template('events/new')
  end

  it 'event created with valid params gets redirected to user page' do
    user = users(:yair)
    log_in user
    post :create, params: { 
      event: {        name: 'Alice Birthday',
                  location: "Wonderland", 
               description: "Spend wonderful time with Alice!",
                      date: DateTime.now,
                creator_id: user.id } }
    expect(flash[:success].present?).to be(true)
    expect(response).to redirect_to(user_path(user))
  end

  it 'event created with invalid params renders template NEW' do
    user = users(:yair)
    log_in user
    post :create, params: { 
      event: {        name: 'Alice Birthday',
                  location: "Wonderland", 
               description: "Spend wonderful time with Alice!",
                creator_id: user.id } }
    expect(response).to render_template('events/new')
  end

  it 'redirects to event path after successful invitation' do
    user = users(:yair)
    log_in user
    post :create, params: { 
      event: {        name: 'Alice Birthday',
                  location: "Wonderland", 
               description: "Spend wonderful time with Alice!",
                      date: DateTime.now,
                creator_id: user.id } }
    event = Event.last
    attendee = users(:jaak)
    get :invite, params: { id: event.id, user_id: attendee.id }
    expect(flash[:success].present?).to be(true)
    expect(response).to redirect_to(event_path(event))
  end

  it 'renders the event path after unsuccessful invitation' do
    user = users(:yair)
    log_in user
    post :create, params: { 
      event: {        name: 'Alice Birthday',
                  location: "Wonderland", 
               description: "Spend wonderful time with Alice!",
                      date: DateTime.now,
                creator_id: user.id } }
    event = Event.last
    attendee = users(:jaak)
    get :invite, params: { id: event.id, user_id: (attendee.id - 1) }
    expect(flash[:danger].present?).to be(true)
    expect(response).to redirect_to(event_path(event))
  end

  it 'return a 200 status code after accepting the invitation to an event' do
    yair = users(:yair)
    attendee = users(:jaak)
    # log_in attendee
    # p current_user.id
    # p current_user.name
    # assert logged_in?
    Event.create(name: 'The best moment', location: "Wonderland", 
          description: "Spend wonderful time with Alice!",
          date: DateTime.now,
          creator_id: yair.id )
    # post :create, params: { event: {
    #       name: 'The best moment',
    #       location: "Wonderland", 
    #   description: "Spend wonderful time with Alice!",
    #           date: DateTime.now,
    #     creator_id: attendee.id 
    # }}
    my_event = Event.last
    get :invite, params: { id: my_event.id, user_id: attendee.id }
    # log_out

    # expect(logged_in?).to be(false)
    # expect(current_user).to be(nil)
    log_in attendee
    assert logged_in?
    
    expect(current_user.name).to eq(attendee.name)
    expect(current_user.id).to eq(attendee.id)
    get :attend, params: { id: my_event.id}
    expect(response.status).to be(302)
    expect(flash[:success]).to be_present
    expect(response).to redirect_to invited_events_path

  end

  it 'renders the show action' do
    yair = users(:yair)
    jaak = users(:jaak)
    log_in yair
    post :create, params: { event: {
      name: 'Interview',
          location: "Wonderland", 
      description: "Spend wonderful time with Alice!",
              date: DateTime.now,
        creator_id: jaak.id 
    }}
    event = Event.last
    get :show, params: { id: event.id}
    expect(response.status).to eq(200)
    expect(response).to render_template :show
  end
  
end