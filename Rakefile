# frozen_string_literal: true

require 'rake'
require 'rake/testtask'
require 'bundler/gem_tasks'

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_change_agent*.rb'
  test.verbose = true
end

desc 'Open console with Change Agent loaded'
task :console do
  exec 'pry -r ./lib/change_agent.rb'
end
