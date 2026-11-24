#!/bin/bash
# Backup script: database dump + web files -> S3, with SNS alert on failure.
# Set the three values below before use.
set -euo pipefail
ARN="YOUR_SNS_TOPIC_ARN"                 # arn:aws:sns:<region>:<account-id>:dr-backup-alerts
BUCKET="s3://YOUR_PRIMARY_BUCKET"        # e.g. s3://nazmeen-dr-primary-2026
REGION="ap-southeast-2"

trap 'aws sns publish --topic-arn "$ARN" --region "$REGION" --subject "DR Backup FAILED" --message "Backup failed on $(hostname) at $(date)"' ERR

TS=$(date +%F_%H%M)
mysqldump --single-transaction --routines --triggers appdb | gzip > /tmp/db_$TS.sql.gz
tar -czf /tmp/files_$TS.tar.gz /var/www/html
aws s3 cp /tmp/db_$TS.sql.gz $BUCKET/db/ --region $REGION
aws s3 cp /tmp/files_$TS.tar.gz $BUCKET/files/ --region $REGION
rm -f /tmp/db_$TS.sql.gz /tmp/files_$TS.tar.gz
echo "$(date) backup OK $TS" >> /var/log/dr_backup.log
