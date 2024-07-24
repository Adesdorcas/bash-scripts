#!/bin/bash

# Install necessary packages
sudo apt-get update
sudo apt-get install -y net-tools lsof docker.io jq

# Ensure Docker service is running
sudo systemctl start docker
sudo systemctl enable docker

# Copy devopsfetch.sh to /usr/local/bin
sudo cp devopsfetch.sh /usr/local/bin/devopsfetch.sh
sudo chmod +x /usr/local/bin/devopsfetch.sh

# Create a log directory
sudo mkdir -p /var/log/devopsfetch
sudo touch /var/log/devopsfetch/devopsfetch.log
sudo chown -R $USER:$USER /var/log/devopsfetch

# Create systemd service
cat << EOF | sudo tee /etc/systemd/system/devopsfetch.service
[Unit]
Description=Devopsfetch Service
After=network.target

[Service]
ExecStart=/usr/local/bin/devopsfetch.sh -t 2023-01-01T00:00:00,2024-01-01T00:00:00
Restart=always
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=devopsfetch
User=$USER

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable devopsfetch.service
sudo systemctl start devopsfetch.service

# Configure log rotation
cat << EOF | sudo tee /etc/logrotate.d/devopsfetch
/var/log/devopsfetch/devopsfetch.log {
    daily
    rotate 14
    compress
    missingok
    notifempty
    create 0640 $USER $USER
    postrotate
        systemctl restart devopsfetch.service > /dev/null
    endscript
}
EOF

echo "Installation complete. The devopsfetch service is now running and logging to /var/log/devopsfetch/devopsfetch.log."
