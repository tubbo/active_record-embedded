begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rdoc/task'
require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rubocop/rake_task'

APP_RAKEFILE = File.expand_path("test/dummy/Rakefile", __dir__)

load 'rails/tasks/engine.rake'
load 'rails/tasks/statistics.rake'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'ActiveRecord::Embedded'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.md')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

RuboCop::RakeTask.new(:lint)

task default: :test
