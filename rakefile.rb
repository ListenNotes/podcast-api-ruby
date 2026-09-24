# frozen_string_literal: true

require 'rake/testtask'
require 'rubygems/package_task'

Rake::TestTask.new(:test) do |task|
  task.libs << 'lib'
  task.test_files = FileList['tests/*_test.rb']
end

Rake::TestTask.new(:integration) do |task|
  task.libs << 'lib'
  task.test_files = FileList['tests/integration/*_test.rb']
end

Gem::PackageTask.new(Gem::Specification.load('podcast_api.gemspec')).define
desc 'Build the gem'
task build: :gem
task default: :test
