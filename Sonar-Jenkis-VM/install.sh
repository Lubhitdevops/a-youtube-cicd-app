#!/bin/bash
set -e

echo "🚀 Starting setup for Jenkins + SonarQube + Docker + Trivy"

# -----------------------------
# Update system
# -----------------------------
sudo apt update -y
sudo apt upgrade -y

# -----------------------------
# Install Java 17
# -----------------------------
echo "☕ Installing Java 17..."
sudo apt install -y openjdk-17-jdk
java -version

# -----------------------------
# Install Jenkins
# -----------------------------
echo "🧱 Installing Jenkins..."
sudo apt install -y curl gnupg2
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update -y
sudo apt install -y jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins

# -----------------------------
# Install Docker
# -----------------------------
echo "🐳 Installing Docker..."
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update -y
sudo apt install -y docker-ce docker-ce-cli containerd.io
sudo systemctl enable docker
sudo systemctl start docker

# Add user to Docker group
sudo usermod -aG docker $USER
sudo usermod -aG docker jenkins
newgrp docker

# -----------------------------
# Run SonarQube container
# -----------------------------
echo "🧠 Running SonarQube container..."
sudo docker pull sonarqube:lts-community
sudo docker run -d --name sonarqube -p 9000:9000 sonarqube:lts-community

# -----------------------------
# Install Trivy
# -----------------------------
echo "🔎 Installing Trivy..."
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sudo sh
export PATH=$PATH:/usr/local/bin

# -----------------------------
# Verify installations (kept same as requested)
# -----------------------------
echo "=========================================="
echo "✅ Installation complete!"
echo "------------------------------------------"
echo "🧩 Java version:"
java -version
echo "------------------------------------------"
echo "🧱 Jenkins status:"
sudo systemctl status jenkins --no-pager
echo "------------------------------------------"
echo "🐳 Docker version:"
docker --version
echo "------------------------------------------"
echo "🔎 Trivy version:"
trivy --version
echo "------------------------------------------"
echo "🌐 Access URLs:"
echo "  Jenkins: http://<your-ec2-public-ip>:8080"
echo "  SonarQube: http://<your-ec2-public-ip>:9000"
echo "=========================================="
