# GitOps K3s AWS — Project Parts Overview

**Part 1 — Cloud Infrastructure (Terraform)**
Provision the VPC, subnet, security group, EC2 instance, and ECR repo as
code, with state stored in S3. Ends with a reachable EC2 box.

**Part 2 — Config Management & Cluster Bootstrap (Ansible + K3s)**
Ansible hardens the OS and installs K3s on that instance. Ends with
`kubectl get nodes` working from your laptop.

**Part 3 — Application Layer (Flask + Docker)**
Build a small Flask app, containerize it, push to ECR manually, deploy
manually with `kubectl apply`. Ends with the app reachable over HTTP.

**Part 4 — CI Pipeline & Security Scanning (GitHub Actions + OIDC + Trivy)**
Automate build → scan → push to ECR, authenticating via OIDC instead of
static AWS keys. Ends with a `git push` producing a scanned image in ECR
automatically.

**Part 5 — GitOps Delivery (ArgoCD)**
Install ArgoCD, point it at your k8s manifests, wire CI to update the
manifest instead of deploying directly. Ends with `git push` → live
deploy, zero manual kubectl.

**Part 6 — Observability (Prometheus, Grafana, Alertmanager)**
Install the monitoring stack via Helm, build one real dashboard, set up
one alert rule. Ends with live metrics and a working alert.

**Part 7 — Incident Simulation & Post-Mortem**
Deliberately break the app under load, capture the alert firing and
recovery with real timestamps, write it up. Ends with your strongest
interview story.

**Part 8 — Polish & CV Packaging**
Finalize the README, verify real costs, record a short demo, clean up
commits, tear down infra when not in use. Ends with a repo you'd
confidently send to a hiring manager.
