node[:applications].each do |app, data|
  sudo "monit -g dj_#{app} restart all"
end

on_app_master do
  #if @configuration[:environment] == 'production'
    config = YAML.load_file File.join(release_path, 'config', 'hipchat.yml')
    client = HipChat::Client.new config['token']
    person = `whoami`

    message  = "#{person} is deploying"
    message += " revision #{@configuration[:revision]}"
    message += " to #{@configuration[:environment]}"
    message += " (with migrations)" if migrate?
    message += "."

    client[config['room']].send(person, message, true)
  #end
end
