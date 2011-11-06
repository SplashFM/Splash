class EventsController < ApplicationController
  respond_to :json

  has_scope :user
  has_scope :follower
  has_scope :count, :type => :boolean
  has_scope :last_update_at
  has_scope :tags, :type => :array

  def index
    events = apply_scopes(Event.scope_builder).page(params[:page])

    respond_with events.build

    # if params[:count]
    #   result = events.build

    #   if result > 0
    #     render :json => result
    #   else
    #     head :no_content
    #   end
    # else
    #   results = events.page(params[:page]).build

    #   if results.empty?
    #     head :no_content
    #   else
    #     render_event_list results
    #   end
    # end
  end
end
