#!/bin/bash

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root"
  exit
fi

# Install necessary packages
apt-get update
apt-get install -y net-tools lsof docker.io jq

# Ensure Docker service is running
systemctl start docker
systemctl enable docker

# Copy devopsfetch.sh to /usr/local/bin
cp devopsfetch.sh /usr/local/bin/devopsfetch.sh
chmod +x /usr/local/bin/devopsfetch.sh

# Create a log directory
mkdir -p /var/log/devopsfetch
touch /var/log/devopsfetch/devopsfetch.log

# Create systemd service
cat << EOF > /etc/systemd/system/devopsfetch.service
[Unit]
Description=Devopsfetch Service
After=network.target

[Service]
ExecStart=/usr/local/bin/devopsfetch.sh -t 2023-01-01T00:00:00,2024-01-01T00:00:00
Restart=always
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=devopsfetch

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
systemctl daemon-reload
systemctl enable devopsfetch.service
systemctl start devopsfetch.service

# Configure log rotation
cat << EOF > /etc/logrotate.d/devopsfetch
/var/log/devopsfetch/devopsfetch.log {
    daily
    rotate 14
    compress
    missingok
    notifempty
    create 0640 root root
    postrotate
        systemctl restart devopsfetch.service > /dev/null
    endscript
}
EOF

echo "Installation complete. The devopsfetch service is now running and logging to /var/log/devopsfetch/devopsfetch.log."
