# frozen_string_literal: true

namespace :docker do
  desc 'Build api-build docker image for circleci'
  task circleci: :environment do
    Dir.chdir('.circleci') do
      sh "docker buildx build --platform linux/amd64 -t safecast/api-build:#{RUBY_VERSION}-amazonlinux2023 . --push"
    end
  end
end
