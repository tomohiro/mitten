require 'rake/clean'

#CLEAN.include('config/test.yml', 'tmp', 'log', '/tmp/rig_issues.*')

namespace :mitten do
  namespace :development do
    desc 'Setup development environments'
    task  :setup do
      sh 'rvm use 1.9.3'
      sh 'rvm gemset create mitten'
      sh 'rvm gemset use mitten'
      sh 'gem install bundler'
      sh 'gem list'
      sh 'bundle install --system'
      sh 'bundle show'
    end
  end
end

begin
  require 'bundler/gem_tasks'
rescue LoadError
  abort 'NOTE: Run `$ rake mitten:development:setup`'
end
