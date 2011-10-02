module RenderHelper
  def render_events(events)
    render :partial => "events/index",
           :object  => events,
           :as      => :events
  end
end
