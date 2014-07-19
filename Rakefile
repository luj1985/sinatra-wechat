require 'rubygems'
require 'rake'
require 'rdoc/task'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

Rake::RDocTask.new do |rdoc|
  version = File.read(File.expand_path('../VERSION', __FILE__)).strip

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "snap #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end