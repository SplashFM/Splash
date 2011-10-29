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
                     popularity_rank,
                     performers,
                     albums )
              SELECT 'DiscoveredTrack', now(), NULL, s.name,
                     s.view_url, s.song_id, s.preview_url,
                     10000,
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

          puts "Updating popularity"

          time do
            up = c.update(<<-TRACKS)
              UPDATE tracks
              SET    popularity_rank = p.rank
              FROM   (SELECT song_id, max(song_rank) rank
                      FROM itunes_song_popularity_per_genre
                      GROUP BY song_id) p
              WHERE  p.song_id = tracks.id
            TRACKS
          end
        end
      end
    end
  end

  namespace :indexes do
    INDEXES = [['index_tracks_for_search',
                "USING gin(to_tsvector('english',
                                       coalesce(title, '') || ' ' ||
                                       coalesce(performers, '') || ' ' ||
                                       coalesce(albums, '')))"],
               ["index_tracks_on_lc_title",
                "(lower(title), lower(performers))"],
               ["index_tracks_on_popularity_rank",
                "(popularity_rank)"]]

    namespace :clobber do
      INDEXES.each { |(i, _)|
        task i => :environment do
          time { |c| c.execute "DROP INDEX #{i}" }
        end
      }
    end

    namespace :restore do
      INDEXES.each { |(i, as)|
        task i => :environment do
          time { |c|
            @indexes ||= begin
                           indexes = c.select_rows <<-IDX
                             SELECT i.relname AS index_name
                             FROM   pg_index ix
                             JOIN   pg_class t ON t.oid = ix.indrelid
                             JOIN   pg_class i ON i.oid = ix.indexrelid
                             WHERE  t.relname = 'tracks'
                           IDX

                           indexes.flatten
                         end

            unless @indexes.include?(i)
              c.execute "CREATE INDEX #{i} ON tracks #{as}"
            end
          }
        end
      }
    end
  end

  namespace :itunes do
    namespace :indexes do
      task :restore do
        indexes = [[:itunes_artist_song, [:song_id, :artist_id]],
                   [:itunes_collection_song, [:song_id, :collection_id]],
                   [:itunes_song_popularity_per_genre, [:song_id]]]

        indexes.each do |(t, cols)|
          cols.each do |col|
            time do |c|
              puts "Creating index on #{t} (#{col})."

              c.execute "CREATE INDEX index_#{t}_on_#{col} ON #{t} (#{col})"
            end
          end
        end
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
