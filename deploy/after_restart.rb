dj_instances = ['solo', 'app_master']
if dj_instances.include?(node[:instance_role])
  node[:applications].each do |app, data|
    sudo "monit -g dj_#{app} restart all"
  end
end

on_app_master do
  message  = "Deploying revision #{@configuration[:revision][0...6]}"
  message += " to #{@configuration[:environment]}"
  message += " (with migrations)" if migrate?
  message += "."

  run "cd #{release_path} && bundle exec rake hipchat:send MESSAGE='#{message}'"
end
