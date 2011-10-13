namespace :tracks do
  desc "Seed tables"
  task :seed => %w(tables:seed)

  desc "Clobber all track related data"
  task :clobber => %w(tables:clobber)

  namespace :tables do
    task :clobber => :environment do
      c = ActiveRecord::Base.connection

      c.execute "truncate table splashes"
      c.execute "truncate table tracks"
    end

    desc "Import all data from iTunes"
    task :seed => %w(seed:tracks)

    namespace :seed do
      task :tracks => :environment do
        limit        = ENV['LIMIT']  && ENV['LIMIT'].to_i
        offset       = ENV['OFFSET'] && ENV['OFFSET'].to_i

        time do |c|
          puts "Inserting tracks."

          time do
            q  = <<-TRACKS
              INSERT INTO tracks (
                     type, created_at, updated_at, title,
                     purchase_url_raw, external_id, preview_url,
                     performers,
                     albums )
              SELECT 'DiscoveredTrack', now(), NULL, s.name,
                     s.view_url, s.song_id, s.preview_url,
                     array_to_string(array(SELECT distinct ai.name
                                           FROM   itunes_artist_song asi
                                           JOIN   itunes_artist ai ON
                                                  ai.artist_id = asi.artist_id
                                           WHERE  asi.song_id = s.song_id
                                           ORDER BY ai.name), ' ;; '),
                     array_to_string(array(SELECT distinct ci.name
                                           FROM   itunes_collection_song csi
                                           JOIN   itunes_collection ci ON
                                                  ci.collection_id = csi.collection_id
                                           WHERE  csi.song_id = s.song_id
                                           ORDER BY ci.name), ' ;; ')
              FROM   itunes_song s
            TRACKS
            q << " LIMIT #{limit}"   if limit
            q << " OFFSET #{offset}" if offset

            up = c.update(q)

            puts "Imported #{up} records."
          end
        end
      end
    end
  end

  namespace :indexes do
    task :clobber do
      time do |c|
        puts "Dropping FT index on tracks."

        c.execute "DROP INDEX index_tracks_for_search"
      end
    end

    task :restore => :environment do
      time do |c|
        puts "Creating FT index on tracks."

        c.execute <<-FT
          CREATE INDEX index_tracks_for_search ON tracks
            USING gin(to_tsvector('english',
                                  coalesce(title, '') || ' ' ||
                                  coalesce(performers, '') || ' ' ||
                                  coalesce(albums, '')))
        FT
      end

      time do |c|
        puts "Creating title + performers index on tracks."

        c.execute "CREATE INDEX index_tracks_on_lc_title
                     ON tracks (lower(title), lower(performers))"
      end

      time do |c|
        puts "Creating popularity index on tracks."

        c.execute "CREATE INDEX index_tracks_on_popularity_rank
                     ON tracks (popularity_rank)"
      end
    end
  end

  def time(&block)
    t = Time.now

    begin
      if block.arity > 0
        yield ActiveRecord::Base.connection
      else
        yield
      end
    rescue
      puts "Failed after #{Time.now - t} seconds."

      raise
    else
      puts "Executed in #{Time.now - t} seconds."
    end
  end
end
