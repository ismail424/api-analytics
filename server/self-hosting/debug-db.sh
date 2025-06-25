#!/bin/bash

echo "=== Database Debug Script ==="
echo "Checking database connection and tables..."

# Check if we can connect to the database
echo "1. Testing database connection..."
docker exec db psql -U ${POSTGRES_USERNAME:-postgres} -d ${POSTGRES_DB:-analytics} -c "SELECT version();"

echo ""
echo "2. Listing all databases..."
docker exec db psql -U ${POSTGRES_USERNAME:-postgres} -d ${POSTGRES_DB:-analytics} -c "\l"

echo ""
echo "3. Listing all tables in current database..."
docker exec db psql -U ${POSTGRES_USERNAME:-postgres} -d ${POSTGRES_DB:-analytics} -c "\dt"

echo ""
echo "4. Checking for users table specifically..."
docker exec db psql -U ${POSTGRES_USERNAME:-postgres} -d ${POSTGRES_DB:-analytics} -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_name='users' AND table_schema='public';"

echo ""
echo "5. If users table exists, show its structure..."
docker exec db psql -U ${POSTGRES_USERNAME:-postgres} -d ${POSTGRES_DB:-analytics} -c "\d users" 2>/dev/null || echo "Users table does not exist"

echo ""
echo "6. Manually applying schema if needed..."
read -p "Do you want to manually apply the schema? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Applying schema..."
    docker exec -i db psql -U ${POSTGRES_USERNAME:-postgres} -d ${POSTGRES_DB:-analytics} < database/schema.sql
    echo "Schema application completed."
fi

echo ""
echo "=== Debug complete ==="
