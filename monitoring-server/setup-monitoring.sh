# monitoring-server/setup-monitoring.sh
#!/bin/bash
set -e

echo "Updating system..."
sudo dnf update -y
sudo dnf install -y wget tar

echo "Creating prometheus user..."
sudo useradd --no-create-home --shell /bin/false prometheus 2>/dev/null || true

PROM_VERSION="2.43.0"

echo "Downloading Prometheus..."
cd /tmp
wget -q https://github.com/prometheus/prometheus/releases/download/v${PROM_VERSION}/prometheus-${PROM_VERSION}.linux-amd64.tar.gz
tar -xzf prometheus-${PROM_VERSION}.linux-amd64.tar.gz

echo "Installing Prometheus..."
sudo mkdir -p /etc/prometheus /var/lib/prometheus
sudo cp prometheus-${PROM_VERSION}.linux-amd64/prometheus /usr/local/bin/
sudo cp prometheus-${PROM_VERSION}.linux-amd64/promtool /usr/local/bin/
sudo cp -r prometheus-${PROM_VERSION}.linux-amd64/consoles /etc/prometheus
sudo cp -r prometheus-${PROM_VERSION}.linux-amd64/console_libraries /etc/prometheus

sudo tee /etc/prometheus/prometheus.yml > /dev/null <<EOF
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]
EOF

sudo chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus

sudo tee /etc/systemd/system/prometheus.service > /dev/null <<EOF
[Unit]
Description=Prometheus
After=network.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl start prometheus

echo "Installing Grafana..."
cd /tmp
wget -q https://dl.grafana.com/oss/release/grafana-10.4.1-1.x86_64.rpm
sudo dnf install -y ./grafana-10.4.1-1.x86_64.rpm

sudo systemctl enable grafana-server
sudo systemctl start grafana-server

echo "Monitoring Server Setup Completed!"
