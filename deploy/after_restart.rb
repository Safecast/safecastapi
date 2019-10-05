# frozen_string_literal: true

sudo 'monit -g dj_safecastapi restart all'
sudo "cp #{release_path}/doc/.pgpass ~/.pgpass"
sudo 'chmod 0600 ~/.pgpass'
