#!/bin/sh
set -e

# bitmagnet reads POSTGRES_PASSWORD straight from the environment (no _FILE
# support), so inject it from the mounted Docker secret before handing off to
# the real binary. Compose passes the `worker run ...` args as $@.
export POSTGRES_PASSWORD=$(cat /run/secrets/bitmagnet_postgres_password)

exec bitmagnet "$@"
