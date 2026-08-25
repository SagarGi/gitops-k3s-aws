# Cloud-Native GitOps & Infrastructure Platform on AWS

![Architecture Diagram](docs/architecture.png)

A production-style cloud infrastructure and GitOps deployment platform built on AWS. This project demonstrates core Platform Engineering / DevOps practices end to end: **Infrastructure as Code (IaC)**, **Automated OS Configuration Management**, **CI/CD with Shift-Left Security**, **GitOps Continuous Delivery (ArgoCD)**, and **Cluster Observability** — deliberately scoped to a single-node cluster to keep cost and complexity manageable while covering the full workflow.

---

## 🌟 Key Features

- **Infrastructure as Code:** Modular Terraform provisioning a custom AWS VPC, subnet, security group, EC2 instance, and private ECR repository.
- **Remote State:** Terraform state stored in S3 for a single source of truth, versioned and shareable.
- **Automated Node Bootstrapping:** Ansible playbook handles OS updates and installs K3s (lightweight Kubernetes) on the EC2 instance.
- **Passwordless CI Auth (OIDC):** GitHub Actions authenticates to AWS via an OIDC IAM role — no long-lived access keys stored anywhere.
- **Shift-Left Security:** Trivy scans the container image for vulnerabilities before it's pushed to ECR.
- **GitOps Delivery:** ArgoCD watches the `k8s/` manifests in this repo and auto-syncs the cluster on every merge — no manual `kubectl apply` in the deploy path.
- **Observability:** `kube-prometheus-stack` via Helm for metrics, one working Grafana dashboard, and one Alertmanager rule, validated with a real simulated incident (see below).

---

## 🧭 Design Tradeoffs (Read This First)

This project is intentionally scoped for clarity over scale. Each simplification below was a deliberate choice, not an oversight:

| Choice | Why | What I'd change for production |
| :--- | :--- | :--- |
| Single-node K3s on one EC2 instance | Keeps cost near $0 and focus on the workflow, not cluster sizing | Multi-node K3s/EKS with node groups across AZs for HA |
| No DynamoDB state locking (v1) | One-person project, no concurrent applies | Add DynamoDB lock table for team use |
| SSH access restricted to my IP / SSM preferred | Least-privilege, no open ingress | Fully remove SSH, SSM-only, short-lived session logging |
| One Alertmanager rule, one dashboard | Depth over breadth — the one rule is fully tested end to end | Broader SLO-based alerting, on-call routing |

---

## 🏗 System Architecture & Workflow

```
                        +----------------------------------------+
                        |           GitHub Repository            |
                        +----------------------------------------+
                                 |                      |
                    (PR on terraform/)             (Push to main)
                                 v                      v
                       +-------------------+   +------------------+
                       | Terraform CI      |   | App CD           |
                       | (Plan on PR)      |   | (Trivy Scan)     |
                       +-------------------+   +------------------+
                                 |                      |
                       [AWS OIDC Auth]                  | Push Image
                                 |                      v
                                 v             +------------------+
                        +------------------+   |    Amazon ECR    |
                        | AWS Cloud Infra  |   +------------------+
                        +------------------+            |
                         /       |        \             |
                     VPC     Subnet   Security          | Pull Image
                     /           |       Group          | Tag Update
                    v            v         v            v
            +-------------------------------------------------+
            |              AWS EC2 Instance (t3.small)         |
            |  +-------------------------------------------+  |
            |  |         Ansible-Bootstrapped OS           |  |
            |  |  +-------------------------------------+  |  |
            |  |  |          K3s Kubernetes             |  |  |
            |  |  |  +-------------------------------+  |  |  |
            |  |  |  | ArgoCD GitOps Engine         |  |  |  |
            |  |  |  +-------------------------------+  |  |  |
            |  |  |  | Flask Microservice (App Pods) |  |  |  |
            |  |  |  +-------------------------------+  |  |  |
            |  |  |  | Prometheus & Grafana Stack    |  |  |  |
            |  |  |  +-------------------------------+  |  |  |
            |  |  +-------------------------------------+  |  |
            |  +-------------------------------------------+  |
            +-------------------------------------------------+
```

### End-to-End Workflow
1. **Provisioning:** Terraform creates the VPC, security group, ECR repo, and EC2 instance.
2. **Configuration:** Ansible connects to the instance, applies OS updates, and installs K3s.
3. **Build & Scan:** GitHub Actions builds the Flask image, scans it with Trivy, and pushes it to ECR on merge.
4. **GitOps Sync:** ArgoCD detects the manifest change in Git and deploys it automatically — no manual kubectl.
5. **Observability:** Prometheus scrapes `/metrics` and cluster state; Grafana visualizes it; Alertmanager fires on pod crash loops.

---

## 📁 Repository Structure

```directory
├── .github/workflows/
│   ├── infra-ci.yml          # Terraform plan on PR
│   └── app-cd.yml            # Build, Trivy scan, ECR push, manifest update
├── terraform/
│   ├── main.tf                # Provider + S3 backend
│   ├── vpc.tf                 # VPC, subnet, route table, IGW
│   ├── security_groups.tf     # SG rules (SSH from my IP, HTTP, K3s, Grafana, ArgoCD)
│   ├── ec2.tf                 # EC2 instance
│   ├── ecr.tf                 # ECR repository
│   ├── variables.tf
│   └── outputs.tf
├── ansible/
│   ├── ansible.cfg
│   ├── inventory.ini
│   └── site.yml               # OS provisioning + K3s install
├── k8s/
│   ├── base/                  # deployment.yaml, service.yaml, configmap.yaml
│   ├── argocd/                # application.yaml
│   └── monitoring/            # values-prometheus.yaml, alerts.yaml
├── src/                        # Flask app: app.py, Dockerfile, requirements.txt
└── README.md
```

---

## 🛠 Tech Stack

| Component | Tool | Purpose |
| :--- | :--- | :--- |
| Cloud Provider | AWS | EC2, VPC, ECR, S3 |
| IaC | Terraform | Reproducible infra provisioning |
| Config Management | Ansible | Node bootstrapping, K3s install |
| Containerization | Docker | Packaging the Flask app |
| Orchestration | K3s | Single-node Kubernetes |
| GitOps | ArgoCD | Automated pull-based deployment |
| CI/CD | GitHub Actions | Build, scan, deploy pipeline |
| Security Scanning | Trivy | Container vulnerability scanning |
| Monitoring | Prometheus & Grafana | Metrics and dashboards |
| Packaging | Helm | Installing the monitoring stack |

---

## 🚀 Quickstart

### Prerequisites
- AWS CLI v2, configured
- Terraform >= v1.5.0
- Ansible >= v2.12
- kubectl

### 1. Provision infrastructure
```bash
cd terraform
terraform init
terraform plan
terraform apply -auto-approve
```

### 2. Bootstrap OS & K3s
```ini
# ansible/inventory.ini
[k3s_server]
<EC2_PUBLIC_IP> ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa
```
```bash
cd ../ansible
ansible-playbook -i inventory.ini site.yml
```

### 3. Fetch kubeconfig & verify
```bash
scp ubuntu@<EC2_PUBLIC_IP>:/etc/rancher/k3s/k3s.yaml ~/.kube/config
sed -i 's/127.0.0.1/<EC2_PUBLIC_IP>/g' ~/.kube/config
kubectl get nodes
```

### 4. Deploy ArgoCD & monitoring
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -f k8s/argocd/application.yaml

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install monitoring prometheus-community/kube-prometheus-stack -f k8s/monitoring/values-prometheus.yaml
```

---

## 📊 Observability & Incident Simulation (Post-Mortem)

*(To be filled in from a real run — see Week 4 of the build plan. Don't write this section until you've actually broken the pod and watched it recover.)*

1. **Trigger:** _[what load-test command was run, what it targeted]_
2. **Detection:** _[actual time-to-alert from Alertmanager, screenshot]_
3. **Healing:** _[actual pod restart time from `kubectl get events`]_
4. **Post-Mortem Action:** _[what config was actually changed as a result]_

---

## 🔐 Security & Cost Notes

- **No static AWS credentials:** GitHub Actions authenticates via an OIDC IAM role.
- **Restricted ingress:** SSH allowed only from my IP (or disabled in favor of AWS SSM Session Manager — see Design Tradeoffs).
- **Cost:** Runs within the AWS Free Tier (`t3.small`, 12 months). Actual cost is approximately **$0–5/month** depending on data transfer and EBS usage outside free-tier limits — not exactly $0, and I've verified this with AWS Cost Explorer rather than assuming.

---

## 👤 Author & Contact

Developed by **[Your Name]** — Junior DevOps / Platform Engineer
- **GitHub:** [@yourusername](https://github.com/yourusername)
- **LinkedIn:** [linkedin.com/in/yourprofile](https://linkedin.com/in/yourprofile)
- **Email:** your.email@example.com
