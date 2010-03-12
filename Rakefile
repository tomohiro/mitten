require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = 'mitten'
    gem.summary = 'IRC Bot Framework'
    gem.description = 'Mitten is A Ruby IRC Bot Pluggable Framework'
    gem.email = 'tomohiro.t@gmail.com'
    gem.homepage = 'http://rubygems.org/gems/mitten'
    gem.authors = ['Tomohiro, TAIRA']
    gem.add_dependency 'net-irc', '>= 0.0.9'
    gem.add_dependency 'daemons', '>= 1.0.10'
    gem.add_dependency 'json_pure', '>= 1.2.0'
    gem.add_development_dependency 'rspec', '>= 1.2.9'
    gem.add_development_dependency 'rake', '>= 0.8.7'
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts 'Jeweler (or a dependency) not available. Install it with: gem install jeweler'
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "mitten #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.options = ['-c', 'utf-8', '-N']
end
