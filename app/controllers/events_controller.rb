class EventsController < ApplicationController
  def index
    render :partial => "events/list",
           :locals  => {:events  => Event.for(current_user, params[:filters])}
  end
end
