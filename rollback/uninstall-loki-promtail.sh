#!/bin/bash
set -e

echo "Stopping Loki and Promtail containers..."
docker stop loki promtail 2>/dev/null || true

echo "Removing Loki and Promtail containers..."
docker rm loki promtail 2>/dev/null || true

echo "Removing Loki and Promtail images..."
docker rmi grafana/loki:2.8.0 grafana/promtail:2.8.0 2>/dev/null || true

echo "Removing configuration files..."
rm -rf ~/grafana_configs/loki-config.yaml
rm -rf ~/grafana_configs/promtail-config.yaml

echo "Cleanup complete! Loki and Promtail have been removed."
