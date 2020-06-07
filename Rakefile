begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rdoc/task'
require 'rake/testtask'

task :default do
	puts "Unknown command. Available commands are: test, rdoc"
end

Rake::TestTask.new(:test) do |t|
	t.libs << "test"
	t.test_files = FileList["test/spec/**/*_test.rb"]
	t.verbose = false
end

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Docker'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end


Bundler::GemHelper.install_tasks

