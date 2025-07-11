#!/bin/bash

# Check if S3 bucket parameter is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <s3-bucket-path>"
    echo "Example: $0 s3://menugraphique-2025-e2025-02/ind250-MenuGraphique/"
    exit 1
fi

S3_BUCKET="$1"

dnf update -y
dnf install -y nginx awscli
systemctl start nginx
systemctl enable nginx

mkdir -p /tmp/website

aws s3 sync "$S3_BUCKET" /tmp/website

cp -r /tmp/website/* /usr/share/nginx/html/
chown -R nginx:nginx /usr/share/nginx/html
