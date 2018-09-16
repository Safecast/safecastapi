FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y postgresql-9.5-postgis-scripts sudo

RUN ["install", "-d", "-m", "2775", "-o", "postgres", "-g", "postgres", "/var/run/postgresql"]

USER postgres

# Replacing template1 with UTF-8 encoding
# See
#   - https://www.postgresql.org/message-id/4C8DF9F5.7050003%40postnewspapers.com.au
#   - https://gist.github.com/ffmike/877447
RUN /etc/init.d/postgresql start && \
  psql --command "CREATE EXTENSION postgis" && \
  createuser -s safecast && \
  psql --command "UPDATE pg_database SET datistemplate = FALSE WHERE datname = 'template1'" && \
  psql --command "DROP DATABASE template1" && \
  psql --command "CREATE DATABASE template1 WITH TEMPLATE = template0 ENCODING = 'UNICODE'" && \
  psql --command "UPDATE pg_database SET datistemplate = FALSE WHERE datname = 'template1'" && \
  psql --command "VACUUM FREEZE" template1

RUN echo "listen_addresses = '*'" >> /etc/postgresql/9.5/main/postgresql.conf

RUN echo "host all safecast 0.0.0.0/0 trust" >> /etc/postgresql/9.5/main/pg_hba.conf
RUN echo "local all all trust\nhost all all 127.0.0.1/32 trust\nhost all safecast 10.0.0.0/8 trust\nhost all safecast 172.16.0.0/12 trust\nhost all safecast 192.168.0.0/16 trust" > /etc/postgresql/9.5/main/pg_hba.conf

USER root

CMD ["pg_ctlcluster", "--foreground", "9.5", "main", "start"]

EXPOSE 5432
