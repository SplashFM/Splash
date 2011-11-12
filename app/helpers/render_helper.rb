module RenderHelper
  def render_upload_form(stage, track = UndiscoveredTrack.new, status = :ok)
    render :partial => "tracks/#{stage}",
           :status  => status,
           :locals  => {:track => track, :splash => Splash.new(params[:splash])}

  end

end
