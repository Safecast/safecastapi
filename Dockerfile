FROM safecast/api-base:2.1.10-1

EXPOSE 3000

ENV BUNDLE_PATH /bundle

ADD . /app
WORKDIR /app

CMD bundle exec rails server
