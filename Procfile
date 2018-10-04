# 1st: Exec rails server 
# 3st: migrate database

web: bundle exec puma -p $PORT -C ./config/puma.rb
release: rake db:migrate
