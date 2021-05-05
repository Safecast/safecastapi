FROM gitpod/workspace-postgres:latest

RUN sudo install-packages postgis postgresql-12-postgis-3
RUN createuser -s safecast