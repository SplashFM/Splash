desc "Sync local environment with $SYNC_REMOTE_DIR on $SYNC_HOST."
task :sync => ['sync:db', 'sync:system', 'db:migrate', 'db:seed']

namespace :sync do

  task :system do
    host, base_dir, db = sync_env
    sh "rsync -av #{host}:#{base_dir}/shared/system/ #{Rails.root}/public/system/"
  end

  task :db => ['db:drop', 'db:create', :environment] do
    host, base_dir, db = sync_env

    dump_dir  = "#{base_dir}/shared/dumps"
    dump_file = File.basename(%x{ssh #{host} 'ls -r #{dump_dir}/*_2*.gz | head -1'}.chomp)
    dump_sql  = "/tmp/#{File.basename(dump_file, '.gz')}"

    raise "Couldn't get latest dump name: '#{dump_file}'" if $? != 0

    unless File.exist?(dump_sql)
      sh "scp #{host}:#{dump_dir}/#{dump_file} /tmp/#{dump_file}"
      sh "gzip -fd /tmp/#{dump_file}"
    end

    cfg  = ActiveRecord::Base.configurations[Rails.env]
    usw  = cfg['username'] ? " -u #{cfg['username']}" : nil
    psw  = cfg['password'] ? " -p '#{cfg['password']}'" : nil
    dbsw = " -D #{db}"

    case ActiveRecord::Base.connection.adapter_name
    when %r{MySQL}i
      sh "mysql#{usw}#{psw}#{dbsw} < #{dump_sql}"
    when "PostgreSQL"
      sh "psql #{usw}#{psw} #{db} < #{dump_sql}"
    else
      raise "Unknown DB adapter: #{ActiveRecord::Base.connection.adapter_name}"
    end
  end

  def sync_env
    host = ENV['SYNC_HOST']
    dir = ENV['SYNC_REMOTE_DIR']
    unless host && dir
      raise "Need SYNC_HOST and SYNC_REMOTE_DIR environment variables."
    end
    [host, dir, ActiveRecord::Base.connection.current_database]
  end
end
