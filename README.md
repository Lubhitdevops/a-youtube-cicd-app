🚀 YouTube CI/CD DevOps Pipeline
📘 Project Overview
This project demonstrates a complete DevOps CI/CD pipeline for a Node.js-based YouTube Clone application.
It automates infrastructure provisioning, code analysis, security scanning, containerization, deployment, and monitoring using a modern DevOps toolchain.

The pipeline covers the entire flow — from a developer pushing code to GitHub, to automatic deployment on Kubernetes with continuous monitoring and feedback.

🧑‍💻 Acknowledgment
Special thanks to Ashfaque-9x —
for the base application code (a-youtube-clone-app) that serves as the foundation for this CI/CD project.

🧰 Tools & Technologies Used
Category	Tools
Version Control & Collaboration	Git, GitHub, GitHub Webhooks
Continuous Integration / Continuous Delivery (CI/CD)	Jenkins
Infrastructure as Code (IaC)	Terraform
Containerization	Docker
Container Security	Trivy
Static Code Analysis	SonarQube
Cluster Orchestration	Kubernetes (K3s / EKS)
Monitoring & Visualization	Prometheus, Grafana, Node Exporter
Notifications	Jenkins Email Extension
Cloud Platform	AWS (EC2, EKS)
Programming & Build Tools	Node.js, NPM
OS & Utilities	Ubuntu 22.04 LTS
🪜 CI/CD Workflow Overview
🧱 Step 1 – Infrastructure Setup (Terraform)
Created Terraform configuration to provision EC2 instances for Jenkins and SonarQube.

After deployment, ran installation scripts (sonar-jenkins/install.sh) to install:

Jenkins

SonarQube

Docker

Trivy

⚙️ Step 2 – Jenkins & SonarQube Configuration
https://image.png

Install Jenkins Plugins:

SonarQube Scanner, Quality Gates

NodeJS

Docker, Docker Pipeline, Docker API, Docker Build Step

Eclipse Temurin installer

Configure Global Tools in Jenkins:

JDK: jdk17

NodeJS: node18

SonarQube Scanner: sonar-scanner

SonarQube Integration:

Generate a token in SonarQube → Add to Jenkins credentials as "Secret Text".

In Jenkins → Manage Jenkins → Configure System → SonarQube Servers → add SonarQube URL & token.

In SonarQube → Administration → Webhooks →

text
Name: jenkins
URL: http://<jenkins-ip>:8080/sonarqube-webhook/
🧩 Step 3 – Jenkins Pipeline Configuration
Here's the Jenkinsfile used for CI/CD automation:

groovy
pipeline {
    agent any
    tools {
        jdk 'jdk17'
        nodejs 'node18'
    }
    environment {
        SCANNER_HOME = tool 'sonar-scanner'
    }
    stages {
        stage('Clean Workspace') { steps { cleanWs() } }
        stage('Checkout from Git') {
            steps { git branch: 'main', url: 'https://github.com/Lubhitdevops/a-youtube-cicd-app.git' }
        }
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube-Server') {
                    sh '''
                    $SCANNER_HOME/bin/sonar-scanner \
                    -Dsonar.projectName=Youtube-CICD \
                    -Dsonar.projectKey=Youtube-CICD
                    '''
                }
            }
        }
        stage('Quality Gate') {
            steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'SonarQube-Token'
                }
            }
        }
        stage('Install Dependencies') { steps { sh 'npm install' } }
        stage('Trivy FS Scan') { steps { sh 'trivy fs . > trivyfs.txt' } }
        stage('Docker Build & Push') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'dockerhub', toolName: 'docker') {
                        sh 'docker build -t youtube-clone .'
                        sh 'docker tag youtube-clone lubhitdocker/youtube-cicd:latest'
                        sh 'docker push lubhitdocker/youtube-cicd:latest'
                    }
                }
            }
        }
        stage('Trivy Image Scan') { steps { sh 'trivy image lubhitdocker/youtube-cicd:latest > trivyimage.txt' } }
🐳 Step 4 – DockerHub Integration
https://image.png

Added DockerHub credentials in Jenkins (dockerhub).

Built and pushed image automatically during the pipeline.

Resulting image:
🔗 DockerHub – lubhitdocker/youtube-cicd

📊 Step 5 – Monitoring (Prometheus & Grafana)
Created Terraform files for provisioning EC2 instances for monitoring.

Installed:

Prometheus

Grafana

Node Exporter

Integrated Prometheus to scrape metrics from Jenkins & Kubernetes.

Imported Grafana dashboards for:

Jenkins Build Performance

Kubernetes Cluster Monitoring

Node Exporter (EC2 metrics)

☸️ Step 6 – Kubernetes Deployment Files
Located inside:

text
Kubernetes/
 ├─ deployment.yml
 └─ service.yml
deployment.yml
yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: youtube-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: youtube-app
  template:
    metadata:
      labels:
        app: youtube-app
    spec:
      containers:
      - name: youtube-app
        image: lubhitdocker/youtube-cicd:latest
        ports:
        - containerPort: 80
service.yml
yaml
apiVersion: v1
kind: Service
metadata:
  name: youtube-app-service
spec:
  type: NodePort
  selector:
    app: youtube-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
      nodePort: 30080
🛠️ Step 7 – Kubernetes + Prometheus Integration (Helm)
Installed and configured Prometheus stack on Kubernetes for pod, node, and service-level monitoring.

bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack
📬 Step 8 – Email Notifications & Kubernetes Deployment
groovy
    post {
        always {
            emailext attachLog: true,
                subject: "'${currentBuild.result}'",
                body: "Project: ${env.JOB_NAME}<br/>" +
                      "Build Number: ${env.BUILD_NUMBER}<br/>" +
                      "URL: ${env.BUILD_URL}<br/>",
                to: 'mlubhit@gmail.com',
                attachmentsPattern: 'trivyfs.txt,trivyimage.txt'
        }
    }
}

stage('Deploy to Kubernetes') {
    steps {
        script {
            dir('Kubernetes') {
                withKubeConfig(credentialsId: 'Kubernetes') {
                    sh 'kubectl apply -f deployment.yml'
                    sh 'kubectl apply -f service.yml'
                }
            }
        }
    }
}
Enabled email notifications with Jenkins Email Extension for success/failure build reports and Trivy scan attachments.

🔄 Step 9 – GitHub Webhook Integration
Generated GitHub Personal Access Token.

Added repo credentials in Jenkins.

Set GitHub hook trigger for GITScm polling.

In GitHub → Settings → Webhooks:

text
Payload URL: http://<jenkins-ip>:8080/github-webhook/
Content type: application/json
Any push to the main branch triggers an automatic pipeline execution.

✅ Outcome
Fully automated CI/CD pipeline from commit → build → scan → deploy → monitor.

Continuous feedback loop through:

SonarQube (Code Quality)

Trivy (Security)

Prometheus & Grafana (Monitoring)

Email Notifications (Build Reports)

📜 License
This project is licensed under the MIT License — feel free to use, modify, and distribute for educational or personal projects.

text
MIT License

Copyright (c) 2025 Lubhit Mawar

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
👨‍💻 Author
Lubhit Mawar
📧 mlubhit@gmail.com
🐳 DockerHub – lubhitdocker
💻 GitHub – Lubhitdevops

🙏 Acknowledgment
Base Application: Ashfaque-9x / a-youtube-clone-app

🌟 Future Enhancements
Automate EKS cluster provisioning via Terraform

Integrate Slack or Teams notifications

Add Canary or Blue-Green deployment strategy

Implement GitOps with ArgoCD

💡 Tech Stack Summary
Layer	Technology
Frontend	React, NPM
Backend	Node.js
DevOps Tools	Jenkins, Terraform, Docker, Trivy, Kubernetes
Monitoring	Prometheus, Grafana
Cloud	AWS
VCS	Git, GitHub
Notifications	Email (SMTP via Jenkins)
✨ End-to-End CI/CD DevOps Pipeline built with love by Lubhit Mawar.
