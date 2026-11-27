#!/bin/sh
set -e

# Apply pending database migrations before starting the API.
# Set RUN_MIGRATIONS=false to skip this (e.g. when migrations run elsewhere).
if [ "${RUN_MIGRATIONS:-true}" = "true" ]; then
  echo "Applying database migrations..."
  ./migrate up
fi

exec ./server
