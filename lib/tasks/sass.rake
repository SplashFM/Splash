namespace :sass do
  desc "convert all sass to css"
  task :compile do
    for file in Dir.glob("#{Rails.root}/public/stylesheets/sass/*s*ss")
       parent = File.new(file).parent
       cmd = "sass #{file} #{file.gsub(/s.ss$/, 'css')}"
       puts cmd
       `#{cmd}`
     end
  end
  
  task :watch do
    execute_sass_task 'watch'
  end

  task :update do
    execute_sass_task 'update'
  end


  def execute_sass_task(task)
    cmd = "sass --#{task} #{Rails.root}/public/stylesheets/sass:#{Rails.root}/public/stylesheets"
    puts cmd
    `#{cmd}`
  end
end
