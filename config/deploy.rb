require 'config/boot'
require 'hoptoad_notifier/capistrano'
require 'hipchat/capistrano'

#Required variables
set :application, "scaphandrier"
require 'bundler/capistrano'
set :scm, "git"
set :scm_verbose, true
set :git_enable_submodules, 1
set :repository,  "git@mojotech.unfuddle.com:mojotech/#{application}.git"
set :branch, "master"

# Optional variables
set :user, "app"
set :deploy_to, "/home/#{user}/#{application}"
set :use_sudo, false
set :deploy_via, :remote_cache
set :notify_email, "dev@mojotech.com"
set :rails_env, "production"

# HipChat integration
set :hipchat_token, "569df1ebf359b6e09bece9bcacf469"
set :hipchat_user, "Deploy"
set :hipchat_room_name, "Mojo Tech"
set :hipchat_announce, false

# Roles
set :host, "#{application}.mojotech.com"
role :app, "#{host}"
role :web, "#{host}"
role :db,  "#{host}", :primary => true
set :db_user, "root"
set :db_type, :mysql # or :postgresql

# Hooks for 'whenever' gem
set :whenever_command, "bundle exec whenever"
require "whenever/capistrano"

# Custom Tasks

desc "Copy config files"
task :copy_config, :roles => [:app] do
  run "for f in #{shared_path}/config/*.yml; do [ -e $f ] && cp $f #{release_path}/config/; done || true"
end

desc "Compile SASS and jam assets"
task :prep_assets, :roles => [:web, :app] do
  run "cd #{release_path} && rake RAILS_ENV=#{rails_env} sass:compile"
  run "cd #{release_path} && RAILS_ENV=#{rails_env} bundle exec jammit"
end

after "deploy:update_code", "copy_config", "prep_assets"

# How to backup the DB
desc "Backup production database"
task :backup, :roles => :db, :only => { :primary => true } do
  db_name = "#{application}_production"
  run "mkdir -p #{shared_path}/dumps/"
  dump_cmd = case db_type
             when :mysql then "mysqldump --single-transaction -u #{db_user}"
             when :postgresql then "pg_dump --clean --no-owner --no-privileges"
             end
  run "#{dump_cmd} #{db_name} | gzip  > #{shared_path}/dumps/#{db_name}_`date +%Y%m%d%H%M%S`.sql.gz"
end

desc "Send deploy notifications"
task :notify, :roles => [:app] do
  run "echo \"To: #{notify_email}\" > #{current_path}/mail.txt"
  run "echo \"Subject: Capistrano Deployment: #{application}\" >> #{current_path}/mail.txt"
  run "echo \"Deployed version #{latest_revision} of branch #{branch} from #{repository} to `hostname` on `date`.\" >> #{current_path}/mail.txt"
  run "echo \"\" >> #{current_path}/mail.txt"
  run "/usr/sbin/sendmail -i -t < #{current_path}/mail.txt"
  run "rm #{current_path}/mail.txt"
end

namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end

  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
end

# Make sure we backup before migrations
before "deploy:migrate", "backup"

# Clean things up
after "deploy", "deploy:cleanup"
after "deploy", "notify"
after "deploy:migrations", "notify"

# For initial setup
after "deploy:setup" do
  ['config', 'dumps'].each do |dir|
    run "mkdir -p #{shared_path}/#{dir} && chmod g+w #{shared_path}/#{dir}"
  end
end

