node[:applications].each do |app, data|
  sudo "monit -g dj_#{app} restart all"
end
