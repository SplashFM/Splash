class RemoveFlatTracksView < ActiveRecord::Migration
  def self.up
    execute "drop view flat_tracks"
  end

  def self.down
    execute <<-SQL
      create view flat_tracks
          (id,
           title,
           album,
           performers,
           data_content_type,
           data_file_name,
           data_file_size,
           data_updated_at) as
        select t.id,
               t.title,
               t.album,
               (select string_agg(name, '|')
                from   artists          ai join
                       track_performers tp on tp.artist_id = ai.id
                where  tp.track_id = t.id),
                t.data_content_type,
                t.data_file_name,
                t.data_file_size,
                t.data_updated_at
        from tracks t
    SQL
  end
end
