module RenderHelper
  def render_events(events, refresh_url)
    render :partial => "events/index",
           :object  => events,
           :as      => :events,
           :locals  => {:refresh_url => refresh_url}
  end

  def refresh_events(events)
    render :partial => "events/list",
           :object  => events,
           :as      => :events
  end
end
