FROM public.ecr.aws/docker/library/ruby:3.0.6

RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg main" >> /etc/apt/sources.list.d/pgdg.list
RUN curl -q https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

RUN apt-get update && apt-get install -y --no-install-recommends \
  libgeos-dev \
  libproj-dev \
  nodejs \
  npm \
  postgresql-client-11 && \
  npm install --global yarn

WORKDIR /src
ADD Gemfile Gemfile.lock .ruby-version /src/
RUN bundle install --jobs=4 --retry=3

CMD [ "bundle", "exec", "rails", "server", "-b", "0.0.0.0" ]
