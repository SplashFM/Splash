module RenderHelper
  def render_events(events)
    render :partial => "shared/feed", :collection => events
  end
end
