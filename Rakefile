require "bundler/gem_tasks"
require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << "lib"
  t.libs << "tests"
  t.pattern = 'tests/**/*_test.rb'
end

Rake::TestTask.new(:run) do |t|
  t.libs << "lib"
  t.libs << "tests"
  t.pattern = ARGV[1]
end

task default: :test
