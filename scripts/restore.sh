#!/bin/bash
# Restore script: run on the DR server. Pulls the newest backups from the
# secondary (replicated) bucket and rebuilds the application.
set -euo pipefail
BUCKET="s3://YOUR_SECONDARY_BUCKET"      # e.g. s3://nazmeen-dr-secondary-2026
REGION="ap-southeast-2"
DBPASS="YOUR_DB_PASSWORD"                # must match the password in app/index.php
START=$(date +%s)

echo "[1/5] Packages check"
export DEBIAN_FRONTEND=noninteractive
if ! command -v apache2 >/dev/null || ! command -v mysql >/dev/null; then
  apt-get update -y
  apt-get install -y apache2 mariadb-server php libapache2-mod-php php-mysql
fi
command -v aws >/dev/null || snap install aws-cli --classic
systemctl enable --now apache2 mariadb

echo "[2/5] Finding latest backups"
DBFILE=$(aws s3 ls $BUCKET/db/ --region $REGION | awk '{print $4}' | sort | tail -1)
FILEFILE=$(aws s3 ls $BUCKET/files/ --region $REGION | awk '{print $4}' | sort | tail -1)
echo "DB backup: $DBFILE"
echo "Files backup: $FILEFILE"

echo "[3/5] Downloading"
aws s3 cp $BUCKET/db/$DBFILE /tmp/restore_db.sql.gz --region $REGION
aws s3 cp $BUCKET/files/$FILEFILE /tmp/restore_files.tar.gz --region $REGION

echo "[4/5] Restoring database"
mysql -e "CREATE DATABASE IF NOT EXISTS appdb; CREATE USER IF NOT EXISTS 'appuser'@'localhost' IDENTIFIED BY '$DBPASS'; GRANT ALL ON appdb.* TO 'appuser'@'localhost'; FLUSH PRIVILEGES;"
gunzip -c /tmp/restore_db.sql.gz | mysql appdb

echo "[5/5] Restoring files"
tar -xzf /tmp/restore_files.tar.gz -C /
systemctl restart apache2

END=$(date +%s)
echo "$(date) RESTORE OK from $DBFILE in $((END-START)) seconds" | tee -a /var/log/dr_restore.log
