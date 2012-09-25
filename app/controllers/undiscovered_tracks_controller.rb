class UndiscoveredTracksController < ApplicationController
  respond_to :html, :only => :show
  respond_to :json

  before_filter :require_superuser, only: %w(show destroy)

  skip_before_filter :require_user, :only => :download
  
  require 'tempfile'
  
  def create
    local = params.slice(:local_data)
    uploadedSong = File.open local[:local_data].tempfile.path
    if is_copyright(uploadedSong) 
      render :json => {:error =>'not ok'}, :status => :non_authoritative_information  
    else
      track = current_user.uploaded_tracks.create(params.slice(:local_data))
      if track.taken?
        canonical = track.replace_with_canonical

        if ! Splash.for?(current_user, canonical)
          respond_with_canonical canonical
        else
          head :im_used
        end
      else
        respond_with track
      end
    end
  end

  def destroy
    UndiscoveredTrack.find(params[:id]).destroy if current_user.superuser?

    render :text => 'Track deleted.'
  end
  


  def download
    if current_user and !Splash.for?(current_user, current_track)
      Splash.create!(:track     => current_track,
                     :user      => current_user)
    end
    redirect_to current_track.download_url
  end

  def flag
    @track = UndiscoveredTrack.find(params[:id])

    AdminMailer.delay.flag(@track, current_user)

    render :json => @track
  end

  def show
    respond_with @track = UndiscoveredTrack.find(params[:id])
  end

  def update
    track = current_user.uploaded_tracks.find(params[:id])

    if track.update_attributes(params.slice(:albums, :title, :performers))
      respond_with(s = splash_and_post(params, track)) { |f|
        f.json { render json: s }
      }
    elsif track.taken?
      begin
        c = track.replace_with_canonical

        respond_with(s = splash_and_post(params, c)) { |f|
          f.json { render json: s }
        }
      rescue ActiveRecord::RecordInvalid => e
        respond_with e.record, :status => :forbidden
      end
    else
      respond_with track
    end
  end

  protected

  def current_track
    @track ||= Track.find(params[:id])
  end

  def respond_with_canonical(canonical)
    respond_with canonical, :status => :ok do |want|
      want.json { render :json => canonical }
    end
  end
  
  def is_copyright(track)
    
    request   = Tempfile.new('request.xml')
    response  = Tempfile.new('response.xml')
    url       = AppConfig.audiblemagic['proxy_url']
    app       = AppConfig.audiblemagic['app_name']
    client    = AppConfig.audiblemagic['app_owner']
    dir       = AppConfig.audiblemagic['libs']
    offset    = 0
    duration  = 55
    
    footprint = "#{dir}/media2xml -c #{client} -a #{app} -u 'admin' -i #{track.path} -e 0123456789 -A -O #{offset} -D #{duration} > #{request.path}"
    
      system footprint
      data = request.read
      
      if data.present?
        postxml = "#{dir}/postxml -i #{request.path} -o #{response.path} -s #{url}"
        system postxml
        data_response = response.read
        response = Hash.from_xml data_response
        if get_status(response) == '2005'
          return false 
        else
         return true
        end   
      else
        puts "Some thing went wrong"
      end
      
      request.close
      request.unlink
      
      response.close
      response.unlink
      
  end
  
  def get_status response_xml      
    response_xml["AMIdServerResponse"]["Details"]["IdResponseInfo"]["IdResponse"]["IdStatus"]
  end
  
end
