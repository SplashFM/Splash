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
                     artwork_url,
                     popularity_rank,
                     performers,
                     albums )
              SELECT 'DiscoveredTrack', now(), NULL, s.name,
                     s.view_url, s.song_id, s.preview_url,
                     (SELECT artwork_url
                      FROM   itunes_collection_song csi
                      JOIN   itunes_collection ci ON
                               ci.collection_id = csi.collection_id
                      WHERE  csi.song_id = s.song_id
                      LIMIT  1),
                     1000,
                     array_to_string(array(SELECT distinct ai.name
                                           FROM   itunes_artist_song asi
                                           JOIN   itunes_artist ai ON
                                                  ai.artist_id = asi.artist_id
                                           WHERE  asi.song_id = s.song_id AND
                                                  ai.is_actual_artist = 't'
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
              FROM   (SELECT song_id, min(song_rank) rank
                      FROM itunes_song_popularity_per_genre
                      GROUP BY song_id) p
              WHERE  p.song_id = tracks.external_id
            TRACKS
          end
        end
      end

      task :tags => :environment do
        time do |c|
          c.execute <<-TAGS
            INSERT INTO tags (name, external_id)
            SELECT DISTINCT g.name, g.genre_id
            FROM   itunes_genre_collection gc
            JOIN   itunes_genre g ON gc.genre_id = g.genre_id
          TAGS
        end

        Rake::Task['tracks:indexes:restore:index_tags_on_external_id'].invoke

        time do |c|
          c.execute <<-TAGGINGS
            INSERT INTO taggings (tag_id, taggable_id, taggable_type, context)
            SELECT DISTINCT tg.id, t.id, 'Track', 'tags'
            FROM   itunes_genre_collection gc
            JOIN   tags tg ON tg.external_id = gc.genre_id
            JOIN   itunes_collection_song cs ON cs.collection_id = gc.collection_id
            JOIN   tracks t ON t.external_id = cs.song_id
          TAGGINGS
        end
      end
    end
  end

  namespace :indexes do
    fts = <<-FTS
      USING gin((
        setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
        setweight(to_tsvector('english', coalesce(performers, '')), 'B') ||
        setweight(to_tsvector('english', coalesce(albums, '')), 'C')
      ))
    FTS
    popular_fts = <<-PFTS
      USING gin((
        setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
        setweight(to_tsvector('english', coalesce(performers, '')), 'B')
      ))
    PFTS
    INDEXES = [['index_tracks_for_search', fts, 'tracks'],
               ['index_tracks_for_popular_search', popular_fts, 'tracks'],
               ["index_tracks_on_lc_title",
                "(lower(title), lower(performers))", 'tracks'],
               ["index_tracks_on_popularity_rank", "(popularity_rank)", 'tracks'],
               ["index_tracks_on_external_id", "(external_id)", 'tracks'],
               ["index_taggings_on_tag_id", "(tag_id)", 'taggings'],
               ["index_taggings_on_scopes", "(taggable_id, taggable_type, context)", 'taggings'],
               ["index_tags_on_name", "(name)", 'tags'],
               ["index_tags_on_external_id", "(external_id)", 'tags']]

    task :clobber => INDEXES.map { |(i, _)| "clobber:#{i}" }
    namespace :clobber do
      INDEXES.each { |(i, _, table)|
        task i => :environment do
          time { |c| c.execute "DROP INDEX #{i}" if indexes[table].include?(i) }
        end
      }
    end

    task :restore => INDEXES.map { |(i, _)| "restore:#{i}" }
    namespace :restore do
      INDEXES.each { |(i, as, t)|
        task i => :environment do
          time { |c|
            unless indexes[t].include?(i)
              c.execute "CREATE INDEX #{i} ON #{t} #{as}"
            end
          }
        end
      }
    end

    def indexes
      @indexes ||= begin
                     c       = ActiveRecord::Base.connection
                     indexes = c.select_rows <<-IDX
                       SELECT t.relname AS table_name, i.relname AS index_name
                       FROM   pg_index ix
                       JOIN   pg_class t ON t.oid = ix.indrelid
                       JOIN   pg_class i ON i.oid = ix.indexrelid
                     IDX

                     indexes.inject(Hash.new { |h, k| h[k] = [] }) { |h, (t, i)|
                       h[t] << i
                       h
                     }
                   end
    end
  end

  namespace :itunes do
    namespace :indexes do
      INDEXES = [['index_ias_on_song_id', '(song_id)', 'itunes_artist_song'],
                 ['index_ias_on_artist_id', '(artist_id)', 'itunes_artist_song'],
                 ['index_ics_on_song_id', '(song_id)', 'itunes_collection_song'],
                 ['index_isp_on_song_id', '(song_id)', 'itunes_song_price_143441'],
                 ['index_ics_on_collection_id', '(collection_id)', 'itunes_collection_song'],
                 ['index_isppg_on_song_id', '(song_id)', 'itunes_song_popularity_per_genre'],
                 ['index_is_on_key', '(song_id)', 'itunes_song'],
                 ['index_igc_on_collection_id', '(collection_id)', 'itunes_genre_collection'],
                 ['index_igc_on_genre_id', '(genre_id)', 'itunes_genre_collection'],
                 ['index_ig_on_key', '(genre_id)', 'itunes_genre']]

      task :restore => :environment do
        c       = ActiveRecord::Base.connection
        indexes = c.select_rows <<-IDX
          SELECT t.relname AS table_name, i.relname AS index_name
          FROM   pg_index ix
          JOIN   pg_class t ON t.oid = ix.indrelid
          JOIN   pg_class i ON i.oid = ix.indexrelid
        IDX

        hash = indexes.inject(Hash.new { |h, k| h[k] = [] }) { |h, (t, i)|
          h[t] << i
          h
        }

        INDEXES.each do |(i, as, t)|
          time do |c|
            puts "Creating index on #{t} #{as}."

            unless hash[t].include?(i)
              c.execute "CREATE INDEX #{i} ON #{t} #{as}"
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
