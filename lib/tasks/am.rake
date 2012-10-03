namespace :audiblemagic do
  desc "generate fingerprints"
  task :media2xml do
      puts "======= here in rake task"  
  end
  
  desc "post xml to api"
  task :postxml do
    puts "======= here in rake task"
    cmd = "/usr/local/lib/linux_64bit/postxml -i ~/response.xml -o ~/postxml_response.xml -s http://amtest.sikeq1.net/amidservice.asvc"  
    #cmd = "~/Documents/postxml -i ~/response.xml -o ~/postxml_response.xml -s http://amtest.sikeq1.net/amidservice.asvc"  
    `#{cmd}`
  end
end
