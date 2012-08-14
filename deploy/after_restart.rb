sudo "monit -g dj_teamdata restart all"
sudo "cp #{release_path}/doc/.pgpass ~/.pgpass"
sudo "chmod 0600 ~/.pgpass"