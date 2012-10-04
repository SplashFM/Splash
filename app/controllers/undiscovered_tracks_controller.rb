class UndiscoveredTracksController < ApplicationController
  respond_to :html, :only => :show
  respond_to :json

  before_filter :require_superuser, only: %w(show destroy)

  skip_before_filter :require_user, :only => :download
  
  require 'tempfile'
  require 'open3'
  
  def create
    local = params.slice(:local_data)
    uploadedSong = File.open local[:local_data].tempfile.path
    status_copyright = is_copyright(uploadedSong)
    if status_copyright == true
      render :json => {:error =>'anauthorize'}, :status => :non_authoritative_information  
    elsif status_copyright == 'error'
      render :json => {:error =>'error_api'}, :status => :unauthorized
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
    request_file   = Tempfile.new('request.xml')
    response_file  = Tempfile.new('response.xml')
    url       = AppConfig.audiblemagic['proxy_url']
    app       = AppConfig.audiblemagic['app_name']
    client    = AppConfig.audiblemagic['app_owner']
    dir       = AppConfig.audiblemagic['libs']
    offset    = 0
    duration  = 55
     
    export_path = "export LD_LIBRARY_PATH=.:#{dir}:$LD_LIBRARY_PATH"
    footprint = "#{dir}/media2xml -c #{client} -a #{app} -u 'admin' -i #{track.path} -e 0123  -A  > #{request_file.path}"  
    logger.info ("=====#{export_path} ; #{footprint}")
    stdin, stdout, stderr = Open3.popen3("#{export_path} ; #{footprint}")  
    logger.info stderr.readlines
    
    logger.info $?
    
    data = request_file.read
    if data.present?
      postxml = "#{dir}/postxml -i #{request_file.path} -o #{response_file.path} -s #{url}"
      stdin, stdout, stderr = Open3.popen3("#{export_path} ; #{postxml}")  
      logger.info stderr.readlines

      logger.info ("==postxml===#{postxml}")
      data_response = response_file.read

      delete_temp_files(request_file)
      delete_temp_files(response_file)
      
      response = Hash.from_xml data_response
      logger.info ("=>Response = #{response}")
      if response.present?
        if get_status(response,'IdStatus') == '2005'
          false 
        elsif get_status(response,'IdStatus') == '2006'
           get_status(response,'Action') == 'Allow' ? false : true
        else
          true
        end   
      else
        logger.info "No response from a-magic"
        false
      end
    else
      logger.info "Some thing went wrong"
      false
    end
  end
  
  def get_status response_xml, tag      
    begin
      response_xml["AMIdServerResponse"]["Details"]["IdResponseInfo"]["IdResponse"][tag] 
    rescue
      logger.info "Xml reading error"
      ""
    end
  end
  
  def delete_temp_files (temp_file)
    temp_file.close
    temp_file.unlink
  end
  
end
