module EventGenerator
  include RenderHelper

  def render_event_updates(count)
    if count > 0
      render :json => count
    else
      head :not_found
    end
  end
end
