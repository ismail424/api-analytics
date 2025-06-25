#!/bin/bash

# Wait for database to be ready
echo "Waiting for database to be ready..."
until docker exec db pg_isready -U ${POSTGRES_USERNAME} -d ${POSTGRES_DB}; do
  echo "Database is not ready yet, waiting..."
  sleep 2
done

echo "Database is ready. Checking if schema needs to be applied..."

# Check if tables exist
RESULT=$(docker exec db psql -U ${POSTGRES_USERNAME} -d ${POSTGRES_DB} -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_name='users' AND table_schema='public';")

if [ "$RESULT" -eq 0 ]; then
    echo "Tables do not exist. Applying schema..."
    docker exec -i db psql -U ${POSTGRES_USERNAME} -d ${POSTGRES_DB} < database/schema.sql
    echo "Schema applied successfully!"
else
    echo "Tables already exist. Skipping schema application."
fi
