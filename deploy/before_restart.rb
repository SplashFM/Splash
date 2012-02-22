@rails_env = node[:environment][:framework_env]
whenever_command = "bundle exec whenever"

#cron_instances = ['solo', 'util']
cron_instances = ['solo', 'app_master']
if cron_instances.include?(node[:instance_role])
  node[:applications].each do |app, data|
    run "cd #{release_path} && #{whenever_command} --update-crontab '#{app}' --set environment=#{@rails_env}"
  end
end

run "cd #{release_path} && bundle exec rails runner -e #{environment} 'Babilu.generate'"
run "cd #{release_path} && bundle exec rake RAILS_ENV=#{environment} sass:compile"
run "cd #{release_path} && bundle exec compass compile -e production"
run "cd #{release_path} && RAILS_ENV=#{environment} bundle exec rake assets:precompile"
run "cd #{release_path} && RAILS_ENV=#{environment} bundle exec jammit  --base-url http://ec2-107-20-221-189.compute-1.amazonaws.com"
