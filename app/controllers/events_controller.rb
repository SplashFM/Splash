class EventsController < ApplicationController
  respond_to :json

  skip_before_filter :require_user

  def index
    events = Event.scope_by(params)

    unless params[:count]
      events.map! { |e|
        if serializer = e.active_model_serializer
          serializer.new(e, current_user)
        else
          e.as_json(:mention_type => 'mention')
        end
      }
    end

    respond_with :last_update_at => Event.timestamp, :results => events
  end
end
