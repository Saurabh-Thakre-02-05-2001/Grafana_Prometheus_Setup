#!/bin/bash
set -e

echo "Stopping node_exporter..."
sudo systemctl stop node_exporter 2>/dev/null || true

echo "Disabling node_exporter..."
sudo systemctl disable node_exporter 2>/dev/null || true

echo "Removing service file..."
sudo rm -f /etc/systemd/system/node_exporter.service
sudo systemctl daemon-reload

echo "Removing binary..."
sudo rm -f /usr/local/bin/node_exporter

echo "Removing user..."
sudo userdel node_exporter 2>/dev/null || true

echo "Worker Node cleanup completed successfully!"
