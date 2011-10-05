namespace :tracks do
  desc "Clobber all track related data and seed (first time)"
  task :clobber_and_seed => %w(tables:clobber
                               ts:prepare
                               tables:seed:main
                               indexes:main:restore
                               seed:joins
                               indexes:joins:restore
                               indexes:ts:restore)

  namespace :tables do
    task :clobber => :environment do
      c = ActiveRecord::Base.connection

      c.execute "truncate table splashes"
      c.execute "truncate table track_genres"
      c.execute "truncate table track_performers"
      c.execute "truncate table album_tracks"
      c.execute "truncate table tracks"
      c.execute "truncate table genres"
      c.execute "truncate table artists"
      c.execute "truncate table albums"
    end

    namespace :seed do
      desc "Import all data from iTunes"
      task :all => %w(main joins)

      task :main => %w(albums artists genres tracks)

      task :joins => %w(album_tracks track_genres track_performers)

      task :albums => :environment do
        c = ActiveRecord::Base.connection

        c.execute <<-ALBUMS
          INSERT INTO albums (name, artwork_url, external_id, source, created_at, updated_at)
          SELECT c.name, c.artwork_url, c.collection_id, 'itunes', now(), NULL
          FROM itunes_collection c;
        ALBUMS
      end

      task :album_tracks => :environment do
        c = ActiveRecord::Base.connection

        c.execute <<-ALBUM_TRACKS
          INSERT INTO album_tracks (album_id, track_id)
          SELECT a.id, t.id
          FROM itunes_collection_song cs
          JOIN tracks t ON cs.song_id = t.external_id
          JOIN albums a ON cs.collection_id = a.external_id;
        ALBUM_TRACKS
      end

      task :artists => :environment do
        c = ActiveRecord::Base.connection

        c.execute <<-ARTISTS
          INSERT INTO artists (name, external_id, source, created_at, updated_at)
          SELECT ia.name, ia.artist_id, 'itunes', now(), NULL
          FROM itunes_artist ia;
        ARTISTS
      end

      task :genres => :environment do
        c = ActiveRecord::Base.connection

        c.execute <<-GENRES
          INSERT INTO genres (name, external_id, source, created_at, updated_at)
          SELECT ig.name, ig.genre_id, 'itunes', now(), NULL
          FROM itunes_genre ig;
        GENRES
      end

      task :tracks => :environment do
        c = ActiveRecord::Base.connection

        c.execute <<-TRACKS
          INSERT INTO tracks (type, created_at, updated_at, title, album, purchase_url_raw, album_art_url, external_id, preview_url)
          SELECT 'DiscoveredTrack', now(), NULL, s.name, NULL, s.view_url, NULL, s.song_id, s.preview_url
          FROM itunes_song s;
        TRACKS
      end

      task :track_genres => :environment do
        c = ActiveRecord::Base.connection

        c.execute <<-TRACK_GENRES
          INSERT INTO track_genres (track_id, genre_id)
          SELECT DISTINCT t.id, g.id
          FROM itunes_genre_collection gc
          JOIN itunes_collection c ON gc.collection_id = c.collection_id
          JOIN itunes_collection_song cs ON c.collection_id = cs.collection_id
          JOIN itunes_genre ig ON ig.genre_id = gc.genre_id
          JOIN tracks t ON cs.song_id = t.external_id
          JOIN genres g ON ig.genre_id = g.external_id
        TRACK_GENRES
      end

      task :track_performers => :environment do
        c.execute <<-TRACK_PERFORMERS
          INSERT INTO track_performers (track_id, artist_id)
          SELECT t.id, a.id
          FROM itunes_artist_song ias
          JOIN tracks t ON ias.song_id = t.external_id
          JOIN artists a ON ias.artist_id = a.external_id;
        TRACK_PERFORMERS
      end
    end
  end

  namespace :indexes do
    MAIN_INDEXES = [[:tracks, :title],
                    [:tracks, :external_id],
                    [:artists, :name],
                    [:artists, :external_id],
                    [:genres, :name],
                    [:genres, :external_id],
                    [:albums, :name],
                    [:albums, :external_id]]

    JOIN_INDEXES = [[:album_tracks, :track_id],
                    [:album_tracks, :album_id],
                    [:track_genres, :track_id],
                    [:track_genres, :genre_id],
                    [:track_performers, :track_id],
                    [:track_performers, :artist_id]]

    FT_INDEXES   = [[:albums, :name],
                    [:artists, :name],
                    [:genres, :name],
                    [:tracks, :title]]

    namespace :main do
      task :clobber => :environment do
        clobber_indexes MAIN_INDEXES
      end

      task :restore => :environment do
        restore_indexes MAIN_INDEXES
      end
    end

    namespace :joins do
      task :clobber => :environment do
        clobber_indexes JOIN_INDEXES
      end

      task :restore => :environment do
        restore_indexes JOIN_INDEXES
      end
    end

    namespace :ts do
      task :clobber => :environment do
        clobber_indexes FT_INDEXES
      end

      task :restore => :environment do
        c = ActiveRecord::Base.connection

        FT_INDEXES.each do |i|
          table, column = *i

          puts "Creating index on #{table} for #{column}."

          c.execute <<-GIN
            create index ft_index_#{column}_on_#{table} on #{table}
              using gin(to_tsvector('english', #{column}))
          GIN
        end
      end
    end

    def clobber_indexes(list)
      c = ActiveRecord::Base.connection

      list.reverse.each do |i|
        table, columns = *i

        puts "Dropping index on #{table} for #{columns}."

        c.execute "drop index index_#{columns}_on_#{table}"
      end
    end

    def restore_indexes(list)
      c = ActiveRecord::Base.connection

      list.each do |i|
        table, columns = *i

        puts "Creating index on #{table} for #{columns}."

        c.execute "create index index_#{columns}_on_#{table} on #{table} (#{columns})"
      end
    end
  end
end
