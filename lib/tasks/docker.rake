namespace :docker do
  desc 'Build api-build docker image for circleci'
  task circleci: :environment do
    image = "safecast/api-build:#{RUBY_VERSION}"
    sh "docker build -f .circleci/Dockerfile -t #{image} ."
    sh "docker push #{image}"
  end
end
