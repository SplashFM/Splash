module RenderHelper
  def render_events(events, refresh_url = nil)
    render :partial => refresh_url ? "events/index" : "events/list",
           :object  => events,
           :as      => :events,
           :locals  => {:refresh_url => refresh_url}
  end
end
