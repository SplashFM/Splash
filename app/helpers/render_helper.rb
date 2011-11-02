module RenderHelper
  def render_events(path_opts)
    render :partial => "events/index",
           :as      => :events,
           :locals  => {:base_url => events_path(path_opts)}
  end

  def render_upload_form(stage, track = UndiscoveredTrack.new, status = :ok)
    render :partial => "tracks/#{stage}",
           :status  => status,
           :locals  => {:track => track, :splash => Splash.new(params[:splash])}

  end

  def render_event_list(events = [])
    render :partial => "events/list",
           :object  => events,
           :as      => :events,
           :locals => {:last_update_at => Event.timestamp}

  end

  private

  def url_for_event_updates(events, id)
    url_for(:action      => 'event_updates',
            :controller  => controller_name,
            :id          => id,
            :last_update => Time.now.iso8601)
  end
end
