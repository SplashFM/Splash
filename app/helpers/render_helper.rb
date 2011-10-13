module RenderHelper
  def render_events(events, id = nil)
    refresh_url = url_for(:controller => controller_name,
                          :action     => 'events',
                          :id         => id)

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
