# -*- mode: ruby -*-
# A sample Guardfile
# More info at https://github.com/guard/guard#readme

interactor :off

guard 'livereload' do
  watch(%r{app/views/.+\.(erb|haml|slim)})
  watch(%r{app/helpers/.+\.rb})
  watch(%r{public/.+\.(css|js|html)}) { |m| m[0] =~ /locales.js$/ ? nil : m }
  watch(%r{config/locales/.+\.yml})
  # Rails Assets Pipeline
  watch(%r{(app|vendor)/assets/\w+/(.+\.(css|js|html)).*})  { |m|
    m[0] =~ %r{javascripts/routes.js} ? nil : "/assets/#{m[2]}"
  }
end
