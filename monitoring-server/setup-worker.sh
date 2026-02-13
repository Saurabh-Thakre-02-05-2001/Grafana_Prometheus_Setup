#worker-node/setup-worker.sh
#!/bin/bash
set -e

echo "Updating system..."
sudo dnf update -y
sudo dnf install -y wget tar

NODE_VERSION="1.7.0"

echo "Creating node_exporter user..."
sudo useradd --no-create-home --shell /bin/false node_exporter 2>/dev/null || true

cd /tmp
wget -q https://github.com/prometheus/node_exporter/releases/download/v${NODE_VERSION}/node_exporter-${NODE_VERSION}.linux-amd64.tar.gz
tar -xzf node_exporter-${NODE_VERSION}.linux-amd64.tar.gz

sudo cp node_exporter-${NODE_VERSION}.linux-amd64/node_exporter /usr/local/bin/
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter

sudo tee /etc/systemd/system/node_exporter.service > /dev/null <<EOF
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter

echo "Worker Node Setup Completed!"
