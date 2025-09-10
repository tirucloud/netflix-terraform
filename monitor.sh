#!/bin/bash
set -e

PROM_VERSION="2.51.2"

echo "[INFO] Starting monitoring stack installation..."

# ----------- Common Setup -----------
echo "[INFO] Updating system..."
apt-get update -y
apt-get install -y software-properties-common apt-transport-https wget curl gnupg

# ----------- Prometheus Installation -----------
if [ ! -x /usr/local/bin/prometheus ]; then
  echo "[INFO] Installing Prometheus v${PROM_VERSION}..."

  # Create Prometheus user
  id prometheus &>/dev/null || useradd --no-create-home --shell /bin/false prometheus

  mkdir -p /etc/prometheus /var/lib/prometheus

  cd /tmp
  wget -q https://github.com/prometheus/prometheus/releases/download/v${PROM_VERSION}/prometheus-${PROM_VERSION}.linux-amd64.tar.gz
  tar xvf prometheus-${PROM_VERSION}.linux-amd64.tar.gz
  cd prometheus-${PROM_VERSION}.linux-amd64

  cp prometheus promtool /usr/local/bin/
  cp -r consoles console_libraries /etc/prometheus

  if [ ! -f /etc/prometheus/prometheus.yml ]; then
    cat <<EOT > /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s
scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]
EOT
  fi

  if [ ! -f /etc/systemd/system/prometheus.service ]; then
    cat <<EOT > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
After=network-online.target

[Service]
User=root
ExecStart=/usr/local/bin/prometheus \\
  --config.file=/etc/prometheus/prometheus.yml \\
  --storage.tsdb.path=/var/lib/prometheus

[Install]
WantedBy=multi-user.target
EOT
  fi

  systemctl daemon-reload
  systemctl enable prometheus
  systemctl start prometheus

  echo "[INFO] Prometheus installed successfully."
else
  echo "[INFO] Prometheus already installed, skipping."
  systemctl restart prometheus || true
fi

# ----------- Grafana Installation -----------
#!/bin/bash
set -e

echo "[INFO] Installing Grafana..."

# Add Grafana repo
apt-get install -y software-properties-common apt-transport-https wget gnupg2 curl
wget -q -O - https://packages.grafana.com/gpg.key | apt-key add -
add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"

# Install Grafana
apt-get update -y
apt-get install -y grafana

# Enable and start service
systemctl enable grafana-server
systemctl start grafana-server

echo "[INFO] Grafana installation completed. Access on port 3000 (default user: admin / admin)."
