# AWS Monitoring Stack (Prometheus + Grafana + Loki + Promtail)

This repository contains scripts to set up a complete monitoring stack using:

- **Prometheus** → Metrics collection  
- **Grafana** → Visualization & Alerts  
- **Node Exporter** → Server metrics  
- **Loki + Promtail** → Centralized log collection  

All scripts are automated and can be run on **Monitoring Server** and **Worker Node**.

---

## 📁 Repository Structure

.
├── monitoring-server/
│ └── setup-monitoring.sh # Prometheus + Grafana setup
│ └── uninstall-monitoring.sh # Cleanup script
├── worker-node/
│ └── setup-worker.sh # Node Exporter setup
│ └── uninstall-worker.sh # Cleanup script
└── README.md

---

## 🖥 1️⃣ Monitoring Server Setup

1. Navigate to monitoring-server folder:

```bash
cd monitoring-server
chmod +x setup-monitoring.sh
./setup-monitoring.sh
```
Access Services:

Prometheus → http://<SERVER-IP>:9090

Grafana → http://<SERVER-IP>:3000

Default Grafana credentials:

Username: admin
Password: admin

🖥 2️⃣ Worker Node Setup
Navigate to worker-node folder:
```
cd worker-node
chmod +x setup-worker.sh
./setup-worker.sh
```
Node Exporter will run on port 9100.

🔗 3️⃣ Add Worker Node to Prometheus
Edit Prometheus config on Monitoring Server:
```
sudo vi /etc/prometheus/prometheus.yml
```
Add your worker node(s):
```
  - job_name: "worker-node"
    static_configs:
      - targets: ["<WORKER-IP>:9100"]
```
Restart Prometheus:
```
sudo systemctl restart prometheus
```

Verify target:

http://<SERVER-IP>:9090/targets

🧹 4️⃣ Uninstall / Cleanup
Monitoring Server
```
cd monitoring-server
chmod +x uninstall-monitoring.sh
./uninstall-monitoring.sh
```
Worker Node
```
cd worker-node
chmod +x uninstall-worker.sh
./uninstall-worker.sh
```
Verify cleanup:
```
systemctl status prometheus
systemctl status grafana-server
systemctl status node_exporter
```
# Expected output: "Unit not found"
🖥 5️⃣ Loki + Promtail + Grafana Logs (Docker Setup)
Install Docker
```
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
```

Create configs directory
```
mkdir -p ~/grafana_configs
cd ~/grafana_configs
```
Download configs
# Loki
```
wget https://raw.githubusercontent.com/grafana/loki/v2.8.0/cmd/loki/loki-local-config.yaml -O loki-config.yaml
```
# Promtail
```
wget https://raw.githubusercontent.com/grafana/loki/v2.8.0/clients/cmd/promtail/promtail-docker-config.yaml -O promtail-config.yaml
```
Run Loki
```
docker run -d \
  --name loki \
  -v $(pwd):/mnt/config \
  -p 3100:3100 \
  grafana/loki:2.8.0 \
  --config.file=/mnt/config/loki-config.yaml
```
Run Promtail
```
docker run -d \
  --name promtail \
  -v $(pwd):/mnt/config \
  -v /var/log:/var/log \
  --link loki \
  grafana/promtail:2.8.0 \
  --config.file=/mnt/config/promtail-config.yaml
```
Connect Loki to Grafana

Grafana → Configuration → Data Sources → Add Data Source → Loki

URL: http://<EC2-IP>:3100

Save & Test

Monitor Logs

Grafana → Explore → Select Loki

Use label filters (job, varlogs)

Example Promtail config for Grafana logs:
```
scrape_configs:
  - job_name: grafana-logs
    static_configs:
      - targets: ["localhost"]
        labels:
          job: grafanalogs
          __path__: /var/log/grafana/*log
```
Restart Promtail after updating config:

docker restart promtail
Grafana Alerts via Gmail

Generate App Password from Gmail (2FA required)

Edit /etc/grafana/grafana.ini:
```
[smtp]
enabled = true
host = smtp.gmail.com:587
user = your-email@gmail.com
password = """<app-password>"""
skip_verify = true
from_address = your-email@gmail.com
from_name = Grafana
```
Restart Grafana:
```
sudo systemctl restart grafana-server
sudo systemctl status grafana-server
```
Configure Alert Rules → Contact Point: Email → Test

