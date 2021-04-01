# frozen_string_literal: true

desc 'Run rubocop'
task :rubocop do
  sh 'rubocop'
end

task spec: [:rubocop]
