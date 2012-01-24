namespace :fts do
  task :create => :environment do
    c = ActiveRecord::Base.connection

    c.execute "create text search configuration songs
                 ( PARSER = pg_catalog.default )"
    c.execute "create text search dictionary song_dict
                 ( TEMPLATE = pg_catalog.simple )"
    c.execute "alter text search configuration songs
                 alter mapping for asciiword, asciihword, hword_asciipart, word,
                                   hword, hword_part, hword_numpart, numword
                 with song_dict"
  end

  task :drop => :environment do
    c = ActiveRecord::Base.connection

    c.execute "drop text search configuration songs"
    c.execute "drop text search dictionary song_dict"
  end
end
