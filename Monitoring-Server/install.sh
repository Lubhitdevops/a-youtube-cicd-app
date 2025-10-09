# Create installation directories
sudo mkdir -p $INSTALL_DIR
cd $INSTALL_DIR

# ------------------------------
# 1. Install Prometheus
# ------------------------------
echo "Installing Prometheus..."
PROM_URL="https://github.com/prometheus/prometheus/releases/download/v${PROM_VERSION}/prometheus-${PROM_VERSION}.linux-amd64.tar.gz"
wget $PROM_URL
tar xvfz prometheus-${PROM_VERSION}.linux-amd64.tar.gz
sudo mv prometheus-${PROM_VERSION}.linux-amd64 prometheus
rm prometheus-${PROM_VERSION}.linux-amd64.tar.gz

# Create systemd service for Prometheus
sudo tee /etc/systemd/system/prometheus.service > /dev/null <<EOF
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=root
ExecStart=${INSTALL_DIR}/prometheus/prometheus \
  --config.file=${INSTALL_DIR}/prometheus/prometheus.yml \
  --storage.tsdb.path=${INSTALL_DIR}/prometheus/data
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# ------------------------------
# 2. Install Node Exporter
# ------------------------------
echo "Installing Node Exporter..."
NODE_URL="https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz"
wget $NODE_URL
tar xvfz node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
sudo mv node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64 node_exporter
rm node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz

# Create systemd service for Node Exporter
sudo tee /etc/systemd/system/node_exporter.service > /dev/null <<EOF
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=root
ExecStart=${INSTALL_DIR}/node_exporter/node_exporter
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# ------------------------------
# 3. Install Grafana
# ------------------------------
echo "Installing Grafana..."
sudo apt-get update
sudo apt-get install -y software-properties-common wget

# Add Grafana repository
wget -q -O - https://packages.grafana.com/gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/grafana-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/grafana-archive-keyring.gpg] https://packages.grafana.com/enterprise/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list

sudo apt-get update
sudo apt-get install -y grafana-enterprise

# Enable and start Grafana
sudo systemctl daemon-reload
sudo systemctl enable grafana-server
sudo systemctl start grafana-server

# ------------------------------
# 4. Start Prometheus & Node Exporter
# ------------------------------
sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl enable node_exporter

sudo systemctl start prometheus
sudo systemctl start node_exporter

# ------------------------------
# 5. Summary
# ------------------------------
echo "-------------------------------------------"
echo "Prometheus: http://<EC2_PUBLIC_IP>:9090"
echo "Node Exporter: http://<EC2_PUBLIC_IP>:9100"
echo "Grafana: http://<EC2_PUBLIC_IP>:3000"
echo "-------------------------------------------"
