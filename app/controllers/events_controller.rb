class EventsController < ApplicationController
  respond_to :json

  has_scope :user
  has_scope :omit_splashes, :type => :boolean
  has_scope :omit_other,    :type => :boolean
  has_scope :follower
  has_scope :last_update_at
  has_scope :tags,          :type => :array

  def index
    events = apply_scopes(Event.scope_builder)

    results = params[:count] ? events.count : events.page(params[:page])

    respond_with(:last_update_at => Event.timestamp,
                 :results        => results.build)

  end
end
