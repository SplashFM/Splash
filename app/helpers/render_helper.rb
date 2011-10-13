module RenderHelper
  def render_events(events, id = nil)
    refresh_url = url_for(:controller => controller_name,
                          :action     => 'events',
                          :id         => id)

    render :partial => "events/index",
           :object  => events,
           :as      => :events,
           :locals  => {:refresh_url => refresh_url,
                        :update_url  => url_for_event_updates(events, id)}
  end

  def refresh_events(events, id = nil)
    render :partial => "events/list",
           :object  => events,
           :as      => :events,
           :locals => {:update_url => url_for_event_updates(events, id)}

  end

  private

  def url_for_event_updates(events, id)
    url_for(:action      => 'event_updates',
            :controller  => controller_name,
            :id          => id,
            :last_update => Time.now.iso8601)
  end
end
