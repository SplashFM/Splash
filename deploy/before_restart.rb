@rails_env = node[:environment][:framework_env]
whenever_command = "bundle exec whenever"

if ['solo', 'util'].include?(node[:instance_role])
  node[:applications].each do |app, data|
    run "cd #{release_path} && #{whenever_command} --update-crontab '#{app}' --set environment=#{@rails_env}"
  end
end
