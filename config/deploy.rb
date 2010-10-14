#Required variables
set :application, "scaphandrier"
set :scm, "git"
set :scm_verbose, true
set :repository,  "git@mojotech.unfuddle.com:mojotech/#{application}.git"
set :branch, "master"

#Optional variables
set :user, "app"
set :deploy_to, "/home/#{user}/#{application}"
set :use_sudo, false
set :deploy_via, :remote_cache
set :notify_email, "dev@mojotech.com"

#Roles
role :app, "monorail.mojotech.com"
role :web, "monorail.mojotech.com"
role :db,  "monorail.mojotech.com", :primary => true

#Custom Tasks

#Copy config files and link upload
task :after_update_code, :roles => [:app] do
  run "cp #{shared_path}/config/*.yml #{release_path}/config/"
  run "cd #{release_path} && rake sass:compile"
  run "cd #{release_path} && jammit"
end

#How to backup the DB
desc "Backup production database"
task :backup, :roles => :db, :only => { :primary => true } do
  db_name = "#{application}_production"
  run "mkdir -p #{shared_path}/dumps/"
  run "mysqldump #{db_name} --single-transaction -u root | gzip  > #{shared_path}/dumps/#{db_name}_`date +%Y%m%d%H%M%S`.sql.gz"
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
  run "mkdir -p #{shared_path}/config && chmod g+w #{shared_path}/config"
end
