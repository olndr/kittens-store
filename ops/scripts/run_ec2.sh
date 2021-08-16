!/usr/bin/env bash
set -ue

#Environment
export RAILS_ENV=development
bundle exec rake db:create
bundle exec rake db:migrate
#bundle exec rspec

# export RAILS_ENV=production
#bundle exec rake db:create
#bundle exec rake db:migrate
bundle exec rake db:seed
bundle exec rackup --port 80 --host 0.0.0.0