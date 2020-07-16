FROM ruby:2.7.1

RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg main" >> /etc/apt/sources.list.d/pgdg.list
RUN curl -q https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

RUN apt-get update && apt-get install -y --no-install-recommends \
  libgeos-dev \
  libproj-dev \
  nodejs \
  postgresql-client-11 \
  python3 \
  python3-pip \
  python3-setuptools \
  python3-wheel

WORKDIR /src
ADD Gemfile Gemfile.lock .ruby-version requirements.txt /src/
RUN LC_ALL=en_US.UTF-8 pip3 install -r requirements.txt
RUN bundle install --jobs=4 --retry=3

CMD [ "bundle", "exec", "rails", "server", "-b", "0.0.0.0" ]
