namespace :db do
  task :refresh => %w(tracks:tables:clobber db:seed_fu)
end
