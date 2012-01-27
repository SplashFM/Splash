Dir[File.join(Rails.root, %w(lib core_ext *.rb))].each { |f|
  require 'core_ext/' + File.basename(f, '.rb')
}
