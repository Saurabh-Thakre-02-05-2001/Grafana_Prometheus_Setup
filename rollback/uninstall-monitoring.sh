#!/bin/bash
set -e

echo "Stopping services..."
sudo systemctl stop prometheus 2>/dev/null || true
sudo systemctl stop grafana-server 2>/dev/null || true

echo "Disabling services..."
sudo systemctl disable prometheus 2>/dev/null || true
sudo systemctl disable grafana-server 2>/dev/null || true

echo "Removing service files..."
sudo rm -f /etc/systemd/system/prometheus.service
sudo systemctl daemon-reload

echo "Removing Prometheus files..."
sudo rm -rf /etc/prometheus
sudo rm -rf /var/lib/prometheus
sudo rm -f /usr/local/bin/prometheus
sudo rm -f /usr/local/bin/promtool

echo "Removing Grafana..."
sudo dnf remove -y grafana 2>/dev/null || true
sudo rm -rf /etc/grafana
sudo rm -rf /var/lib/grafana

echo "Removing users..."
sudo userdel prometheus 2>/dev/null || true

echo "Monitoring Server cleanup completed successfully!"
