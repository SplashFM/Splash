class EventsController < ApplicationController
  respond_to :json

  def index
    respond_with(:last_update_at => Event.timestamp,
                 :results        => Event.scope_by(params))
  end
end
