require "bundler/gem_tasks"
require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << "lib"
  t.libs << "tests"
  t.pattern = 'tests/**/*_test.rb'
end

task default: :test
