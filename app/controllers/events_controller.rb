class EventsController < ApplicationController
  respond_to :json

  def index
    sth = current_user.try(:splashed_tracks_hash)
    respond_with(:last_update_at => Event.timestamp,
                 :results        => Event.scope_by(params).
                 as_json(:splashed_tracks => sth,
                         :mention_format  => 'mention'))
  end
end
