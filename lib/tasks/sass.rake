namespace :sass do
  desc "convert all sass to css"
  task :compile do
    for file in Dir.glob("#{Rails.root}/public/stylesheets/*scss")
      cmd = "sass #{file} #{file.gsub(/scss$/, 'css')}"
      puts cmd
      `#{cmd}`
    end
  end
end
