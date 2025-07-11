#!/bin/bash

# Check if S3 bucket parameter is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <s3-bucket-path>"
    echo "Example: $0 s3://menugraphique-2025-e2025-02/ind250-Artifact-main/"
    exit 1
fi

S3_BUCKET="$1"

# Install dependencies
dnf update -y
dnf install -y java-21-amazon-corretto-headless awscli

# Create webservice directory and sync app files
mkdir -p /opt/webservice
cd /opt/webservice
aws s3 sync "$S3_BUCKET" .

# Ensure the jar is executable
chmod +x /opt/webservice/WebServer/WebServer-0.0.1-SNAPSHOT.jar

# Set environment variables (no "export" — systemd doesn't accept that)
cat <<EOF | tee /etc/webserver_env.conf
WEBSERVER_PORT=80
WEBSERVER_CRYPTOSERVER=licence.andrew.team2.ind250.ets.bimweb.net
WEBSERVER_CRYPTOSERVERPORT=8080
WEBSERVER_CRYPTOLICENCE=3c12dd6bc9990d4a337162449208495e:fbaa260819b5680ca093330c2b8742089ca15521ab23ac977397512fbda7bb8af50f3e6f9f02c5e7d32faba94ea82da7
WEBSERVER_DBHOST=bd.andrew.team2.ind250.ets.bimweb.net
WEBSERVER_DBPORT=3306
WEBSERVER_DBUSER=ind250
WEBSERVER_DBPASSWORD=ind250psw
EOF

# Create systemd service
cat <<EOF | tee /etc/systemd/system/webapp.service
[Unit]
Description=Java Web Service
After=network.target

[Service]
Type=simple
WorkingDirectory=/opt/webservice/WebServer
EnvironmentFile=/etc/webserver_env.conf
ExecStart=/usr/bin/java \\
  -Dserver.port=\${WEBSERVER_PORT} \\
  -Dcrypto.server=\${WEBSERVER_CRYPTOSERVER} \\
  -Dcrypto.server.port=\${WEBSERVER_CRYPTOSERVERPORT} \\
  -Dcrypto.licence=\${WEBSERVER_CRYPTOLICENCE} \\
  -Dspring.datasource.url=jdbc:mariadb://\${WEBSERVER_DBHOST}:\${WEBSERVER_DBPORT}/webapp \\
  -Dspring.datasource.username=\${WEBSERVER_DBUSER} \\
  -Dspring.datasource.password=\${WEBSERVER_DBPASSWORD} \\
  -jar /opt/webservice/WebServer/WebServer-0.0.1-SNAPSHOT.jar
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and start the service
systemctl daemon-reload
systemctl enable webapp.service
systemctl start webapp.service
