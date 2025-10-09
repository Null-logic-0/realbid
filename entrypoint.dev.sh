#!/bin/sh
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /rails/tmp/pids/server.pid

# Install Ruby gems if not installed yet
if [ ! -f /usr/local/bundle/config ]; then
  echo "Installing Ruby gems..."
  bundle install
fi


# If you’re running production (not dev), precompile assets
if [ "$RAILS_ENV" = "production" ]; then
  echo "Recompiling assets..."
  bundle exec rails assets:precompile
fi

# If in development, use bin/dev for Hotwire (Turbo + Stimulus)
if [ "$RAILS_ENV" = "development" ]; then
  echo "Starting Rails (Hotwire mode with JS/CSS watchers)..."
  exec bin/dev
else
  exec "$@"
fi
