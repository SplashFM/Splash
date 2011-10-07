node[:applications].each do |app, data|
  sudo "monit -g dj_#{app} restart all"
end

on_app_master do
  message  = "Deploying revision #{@configuration[:revision]}"
  message += " to #{@configuration[:environment]}"
  message += " (with migrations)" if migrate?
  message += "."

  # Send a message via rake task assuming a hipchat.yml in your config like above
  run "cd #{release_path} && rake hipchat:send MESSAGE=#{message}"
end
