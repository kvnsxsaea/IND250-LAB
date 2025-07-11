#!/bin/bash

# Check if S3 bucket parameter is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <s3-bucket-path>"
    echo "Example: $0 s3://menugraphique-2025-e2025-02/ind250-SecureServer/"
    exit 1
fi

S3_BUCKET="$1"

# Pour verifier que le script est bien parti, verifie avec : systemctl status secure-server

dnf update -y
dnf install -y nodejs awscli

mkdir -p /opt/secure-server
chown ec2-user:ec2-user /opt/secure-server

# Run commands as ec2-user
sudo -u ec2-user bash <<EOF

cd /opt/secure-server

aws s3 sync "$S3_BUCKET" .

# package-lock.json and node_modules were giving issues, so we remove them and reinstall
rm -f package-lock.json
rm -rf node_modules
npm install

EOF

# Create systemd service file to run the node app
cat <<EOF > /etc/systemd/system/secure-server.service
[Unit]
Description=Secure Node.js Server
After=network.target

[Service]
ExecStart=/usr/bin/node /opt/secure-server/index.js
WorkingDirectory=/opt/secure-server
Restart=always
RestartSec=5
User=ec2-user
Group=ec2-user

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable secure-server
systemctl start secure-server
