#!/bin/bash
# postgres-setup.sh
# Cloud-init style user data script for the "postgres-lite" EC2 instance.
# This script:
#  - Formats and mounts a separate EBS volume for Postgres data.
#  - Installs Postgres (demo only, using OS packages).
#  - Initializes the database and creates a demo user + database.
#  - Enables remote connections and loosens pg_hba.conf for the app subnet.
# This is intentionally simplified and should NOT be used as-is in production.

set -euo pipefail

DB_NAME="${db_name}"
DB_USER="${db_username}"
DB_PASSWORD="${db_password}"

DATA_DEVICE="/dev/xvdb"
DATA_MOUNT_POINT="/var/lib/pgsql"

echo "[postgres-setup] Starting configuration"

echo "[postgres-setup] Installing PostgreSQL server packages"
yum update -y
yum install -y postgresql-server postgresql-contrib

echo "[postgres-setup] Preparing data volume at $${DATA_DEVICE}"
mkfs -t xfs "$${DATA_DEVICE}"
mkdir -p "$${DATA_MOUNT_POINT}"
mount "$${DATA_DEVICE}" "$${DATA_MOUNT_POINT}"

echo "[postgres-setup] Persisting mount in /etc/fstab"
UUID=$(blkid -s UUID -o value "$${DATA_DEVICE}")
echo "UUID=$${UUID} $${DATA_MOUNT_POINT} xfs defaults,nofail 0 2" >> /etc/fstab

echo "[postgres-setup] Initializing database cluster"
postgresql-setup initdb

PGDATA="/var/lib/pgsql/data"

echo "[postgres-setup] Configuring PostgreSQL to listen on all interfaces"
sed -i "s/^#listen_addresses = 'localhost'/listen_addresses = '*'/g" "$${PGDATA}/postgresql.conf"

echo "[postgres-setup] Updating pg_hba.conf to allow remote connections (demo-only, trust app subnet via security group)"
echo "host    all             all             0.0.0.0/0               md5" >> "$${PGDATA}/pg_hba.conf"

echo "[postgres-setup] Enabling and starting PostgreSQL service"
systemctl enable postgresql
systemctl start postgresql

echo "[postgres-setup] Creating demo database and user"
sudo -u postgres psql <<EOF
CREATE USER $${DB_USER} WITH PASSWORD '$${DB_PASSWORD}';
CREATE DATABASE $${DB_NAME} OWNER $${DB_USER};
GRANT ALL PRIVILEGES ON DATABASE $${DB_NAME} TO $${DB_USER};
EOF

echo "[postgres-setup] Postgres-lite setup complete"


