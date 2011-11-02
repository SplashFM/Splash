class EventsController < ApplicationController
  include RenderHelper

  has_scope :user
  has_scope :follower
  has_scope :count, :type => :boolean
  has_scope :last_update_at
  has_scope :tags, :type => :array

  def index
    events = apply_scopes(Event.scope_builder).build

    if params[:count]
      if events > 0
        render :json => events
      else
        head :no_content
      end
    else
      render_event_list events
    end
  end
end
