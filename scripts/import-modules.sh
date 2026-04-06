#!/bin/bash
set -e

HOST="ac-database"
USER="root"
PASS="${DOCKER_DB_ROOT_PASSWORD:-password}"
MYSQL="mysql -h${HOST} -u${USER} -p${PASS}"

echo ">> Waiting for database to be ready..."
until $MYSQL -e "SELECT 1;" > /dev/null 2>&1; do
  echo "   Waiting..."
  sleep 2
done

echo ">> Checking if module SQL already imported..."
if $MYSQL acore_world -e "SELECT 1 FROM custom_quest_xp LIMIT 1;" > /dev/null 2>&1; then
  echo ">> Module SQL already imported. Skipping."
  exit 0
fi

echo ">> Importing mod-individual-progression world SQL..."
for f in $(ls /modules/mod-individual-progression/data/sql/world/base/*.sql | sort); do
  echo "   $f"
  $MYSQL acore_world < "$f" 2>&1 || true
done

echo ">> Importing mod-playerbots world SQL..."
for f in $(ls /modules/mod-playerbots/data/sql/world/base/*.sql | sort); do
  echo "   $f"
  $MYSQL acore_world < "$f" 2>&1 || true
done

echo ">> Importing mod-playerbots characters SQL..."
for f in $(ls /modules/mod-playerbots/data/sql/characters/base/*.sql | sort); do
  echo "   $f"
  $MYSQL acore_characters < "$f" 2>&1 || true
done

echo ">> Importing mod-playerbots playerbots DB SQL..."
for f in $(ls /modules/mod-playerbots/data/sql/playerbots/base/*.sql | sort); do
  echo "   $f"
  $MYSQL acore_playerbots < "$f" 2>&1 || true
done

echo ">> Module SQL import complete!"
