class TracksController < ApplicationController
  TRACKS_PER_SEARCH_PAGE       = 5
  TRACKS_PER_SHORT_SEARCH_PAGE = 3
  TRACKS_PER_ALL_RESULTS_PAGE  = 50
  TRACKS_PER_PAGE              = 10
  TRACK_TAB                    = 1
  ITUNES_URL                   = "http://itunes.apple.com/lookup?entity=song&upc="

  respond_to :json

  skip_before_filter :require_user, :only => :index

  def index
    following = params[:following].present?
    week      = params[:week].present?

    if params[:top]
      results = if following
                  if current_user
                    current_user.top_tracks(week, current_page, TRACKS_PER_PAGE)
                  else
                    head :unauthorized and return
                  end
                else
                  Track.top_splashed(week, current_page, TRACKS_PER_PAGE)
                end
    else
      per = if params[:popular].present?
              if params[:short].blank?
                TRACKS_PER_SEARCH_PAGE
              else
                TRACKS_PER_SHORT_SEARCH_PAGE
              end
            else
              TRACKS_PER_ALL_RESULTS_PAGE
            end

      results = Track.
        with_text(params[:with_text], params[:popular].present?).
        page(current_page).
        per(per)
    end

    respond_with results.map { |t|
      t.active_model_serializer.new(t,
                                    current_user,
                                    :scoped_score => true)
    }
  end

  def top
    @selected_tab = TRACK_TAB

    render :template => 'splashboards/index'
  end
  
  # IoS web service 
  # Get Itunes 30 sec song preview  
  
  def splash_discovered_track
    input_xml     = Hash.from_xml params[:xml]
    album_upc     = get_track_info input_xml, "AlbumUPC" 
    track_number  = get_track_info input_xml, "Track"      
    msg           = ''
    
    if album_upc.nil? or track_number.nil?
      msg = {:status => "failure", :message => "data_missing"}
      render :json => msg.to_json
      return
    end
    
    itunes_url    = ITUNES_URL + album_upc
    @data         = HTTParty.get(itunes_url).parsed_response
     
    unless @data.present? and @data['resultCount'] > 0
      msg = {:status => "failure", :message => "itunes_unavailable"}
      render :json => msg.to_json
      return
    end
        
    @data['results'].each do |track|
      if track['wrapperType'] == 'track' and track['trackNumber'].to_i == track_number.to_i
        if Track.find_by_title(track['trackName']).present?
          current_track = Track.find_by_title(track['trackName'])
        else
          current_track = current_user.discovered_uploaded_tracks.create( track_info(track) )
        end
        if current_user and !Splash.for?(current_user, current_track)
          Splash.create!(:track => current_track,
                         :user  => current_user)
           msg = {:status => "success", :message => "splashed"}
          break
        else
           msg = {:status => "success", :message => "already_splashed"}
        end
      end
    end
    render :json => msg.to_json
  end
  
  def track_info track
    { :title            => track['trackName'], 
      :artwork_url      => track['artworkUrl60'], 
      :preview_url      => track['previewUrl'] , 
      :performers       => track['artistName'], 
      :albums           => track['collectionName'],
      :purchase_url_raw => track['trackViewUrl']
    }
  end
  
  def get_track_info track, field
    track["AMIdServerResponse"]["Details"]["IdResponseInfo"]["IdResponse"]["IdDetails"]["Music"][field]
  end
end
