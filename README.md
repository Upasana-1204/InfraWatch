# InfraWatch 🔭
### VM-Based Real-Time DevOps Monitoring & Alerting System

![CI Pipeline](https://github.com/Upasana-1204/InfraWatch/actions/workflows/deploy.yml/badge.svg)
![Platform](https://img.shields.io/badge/Platform-AWS%20EC2-orange)
![Tools](https://img.shields.io/badge/Tools-12%20DevOps-blue)
![Status](https://img.shields.io/badge/Status-Live-brightgreen)
![License](https://img.shields.io/badge/License-MIT-green)

---

## 📌 Project Overview

**InfraWatch** is a cloud-native, real-time infrastructure monitoring and alerting system built on **AWS EC2 Virtual Machines**. It continuously collects, stores, visualizes, and alerts on key hardware performance metrics — enabling proactive incident response before users are impacted.

> **Real-world scenario:** In a banking system, services like fund transfers, account balance checks, and loan processing must be available 24×7. During peak hours (salary credit days, festive seasons), VMs experience CPU spikes and memory exhaustion. InfraWatch detects these anomalies in real time and instantly alerts administrators — preventing transaction failures and service outages.

---

## 🖥️ What is a VM in this project?

This project uses **AWS EC2 (Elastic Compute Cloud)** instances as Virtual Machines (VMs). An EC2 instance is a virtualized server running on AWS physical infrastructure — identical in concept to a traditional VM but hosted in the cloud.

| Term | What it means in InfraWatch |
|------|-----------------------------|
| Virtual Machine (VM) | AWS EC2 instance running Ubuntu 24.04 LTS |
| Monitored node | EC2 instance with Telegraf agent installed |
| Monitoring server | Central EC2 instance running InfluxDB + Grafana + Loki |
| Cloud provider | Amazon Web Services (AWS) — ap-south-1 (Mumbai) |

Each EC2 VM runs a **Telegraf agent** that collects system metrics every 10 seconds and ships them to a central InfluxDB database — exactly mirroring how enterprise infrastructure monitoring works in production environments.

---

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    DEVELOPER MACHINE (Local)                     │
│                                                                   │
│   GitHub Repo  ──►  GitHub Actions CI/CD  ──►  SonarCloud       │
│   Terraform    ──►  Provision AWS EC2                            │
│   Ansible      ──►  Auto-install monitoring stack                │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                  AWS EC2 — Ubuntu 24.04 LTS                      │
│                  (Virtual Machine — ap-south-1)                  │
│                                                                   │
│  ┌─────────────┐    ┌─────────────┐    ┌──────────────────────┐ │
│  │  Telegraf   │───►│  InfluxDB   │───►│       Grafana        │ │
│  │ (agent)     │    │ (time-series│    │  (dashboards +       │ │
│  │ every 10s   │    │  database)  │    │   alert rules)       │ │
│  └─────────────┘    └─────────────┘    └──────────────────────┘ │
│                                                  │               │
│  ┌─────────────┐    ┌─────────────┐             │               │
│  │  Promtail   │───►│    Loki     │─────────────┘               │
│  │ (log agent) │    │ (log store) │                              │
│  └─────────────┘    └─────────────┘                             │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
              ┌───────────────────────────────┐
              │         ALERT CHANNELS         │
              │                               │
              │  📱 Telegram Bot (instant)    │
              │  📧 Email SMTP (formal)       │
              └───────────────────────────────┘
```

---

## 🛠️ Tools & Technologies

### Monitoring Stack
| Tool | Version | Purpose |
|------|---------|---------|
| **Telegraf** | 1.30.0 | Lightweight metrics collection agent installed on each VM. Reads CPU, memory, disk, network data from Linux kernel every 10 seconds |
| **InfluxDB** | 1.8 | Time-series database that stores all VM performance metrics. Optimized for high-frequency write operations and time-range queries |
| **Grafana** | 12.x | Open-source visualization platform. Provides real-time dashboards, threshold-based alerting, and multi-datasource support |
| **Loki** | 2.9.0 | Log aggregation system by Grafana Labs. Stores and indexes log streams from all VMs for centralized log monitoring |
| **Promtail** | 2.9.0 | Log shipping agent. Tails log files on the VM and forwards them to Loki in real time |

### Infrastructure & CI/CD
| Tool | Purpose |
|------|---------|
| **Terraform** | Infrastructure as Code — provisions AWS EC2 instances, security groups, and networking with a single `terraform apply` command |
| **Ansible** | Configuration management — automatically installs and configures the entire monitoring stack on any new EC2 VM via playbook |
| **GitHub Actions** | CI/CD pipeline — validates Telegraf config syntax and Grafana dashboard JSON on every git push |
| **SonarCloud** | Static code analysis — scans configuration files and scripts for quality issues on every commit |

### Cloud & Alerting
| Tool | Purpose |
|------|---------|
| **AWS EC2** | Virtual Machines hosting the monitoring infrastructure — t3.micro Ubuntu 24.04 in ap-south-1 |
| **AWS Security Groups** | Network firewall rules — controls inbound access to ports 22 (SSH), 3000 (Grafana), 8086 (InfluxDB), 3100 (Loki) |
| **Telegram Bot API** | Instant push notifications to mobile — fires within seconds of threshold breach |
| **Gmail SMTP** | Formal email alerts — sent via Gmail with App Password authentication |

---

## 📊 Grafana Dashboard Panels

| Panel | Type | Query | What it shows |
|-------|------|-------|--------------|
| CPU Usage % | Time series | `mean(usage_user + usage_system)` | Real-time CPU utilization trend |
| Memory Usage % | Time series | `mean(used_percent) FROM mem` | RAM consumption over time |
| Disk Usage % | Gauge | `mean(used_percent) FROM disk` | Root filesystem usage |
| Network Traffic | Time series | `derivative(bytes_recv/sent)` | Inbound + outbound bytes/sec on ens5 |
| System Uptime | Stat | `last(uptime) FROM system` | Time since last reboot |
| CPU Live Value | Stat | `last(usage_user) FROM cpu` | Current CPU % with color threshold |
| Memory Live Value | Stat | `last(used_percent) FROM mem` | Current RAM % with color threshold |
| Disk Live Value | Stat | `last(used_percent) FROM disk` | Current disk % with color threshold |
| Active Processes | Stat | `last(running) FROM processes` | Number of running processes |
| Disk I/O | Time series | `derivative(reads/writes)` | Read and write operations per second |
| System Load | Time series | `mean(load1/load5/load15)` | 1min, 5min, 15min load averages |
| System Logs | Logs | `{job="varlogs"}` | Live log stream from /var/log via Loki |

---

## 🚨 Alert Configuration

| Metric | Warning | Critical | Channel | Repeat |
|--------|---------|----------|---------|--------|
| CPU Usage | 60% | 80% | Telegram + Email | Every 15 min |
| Memory Usage | 70% | 85% | Telegram + Email | Every 15 min |
| Disk Usage | 75% | 90% | Telegram + Email | Every 15 min |

Alerts are evaluated every **1 minute**. A threshold must be breached for **2 consecutive minutes** before firing to avoid false positives.

---

## 🚀 How to Deploy

### Prerequisites
- AWS account with IAM user (AdministratorAccess)
- AWS CLI configured (`aws configure`)
- Terraform installed
- Ansible installed
- SSH key pair created in AWS

### Step 1 — Clone the repository
```bash
git clone https://github.com/Upasana-1204/InfraWatch.git
cd InfraWatch
```

### Step 2 — Provision AWS EC2 with Terraform
```bash
cd terraform
terraform init
terraform plan
terraform apply
# Note the EC2 public IP from the output
```

### Step 3 — Install monitoring stack with Ansible
```bash
cd ../ansible
# Update inventory.ini with your EC2 IP
ansible-playbook -i inventory.ini playbook.yml
```

### Step 4 — Access Grafana
```
http://YOUR_EC2_IP:3000
Default credentials: admin / admin (change immediately)
```

### Step 5 — Import dashboard
- Grafana → Dashboards → Import
- Upload `grafana/dashboards/infrawatch.json`
- Select InfluxDB as data source
- Click Import

---

## 📁 Repository Structure

```
InfraWatch/
├── .github/
│   └── workflows/
│       └── deploy.yml          # GitHub Actions CI/CD pipeline
├── terraform/
│   ├── main.tf                 # EC2 instance + security group
│   ├── variables.tf            # Region, AMI, instance type
│   └── outputs.tf              # Public IP, Grafana URL
├── ansible/
│   ├── playbook.yml            # Install TIG stack + Loki
│   └── inventory.ini           # EC2 host configuration
├── telegraf/
│   └── telegraf.conf           # Metrics collection config
├── grafana/
│   └── dashboards/
│       └── infrawatch.json     # Complete dashboard export
├── loki/
│   └── loki-config.yml         # Log storage configuration
├── promtail/
│   └── promtail-config.yml     # Log shipping configuration
├── sonar-project.properties    # SonarCloud analysis config
└── README.md                   # This file
```

---

## 📈 Project Outcomes

| Metric | Value |
|--------|-------|
| Alert detection time | < 2 minutes |
| Metrics collection interval | 10 seconds |
| Dashboard refresh rate | 10 seconds |
| Manual setup steps after Ansible | 0 |
| DevOps tools integrated | 12 |
| Phases completed | 7 |
| Alert channels | 3 (Telegram, Email, Grafana UI) |

---

## 🔄 CI/CD Pipeline

Every `git push` to `main` automatically triggers:

```
Push to GitHub
      │
      ▼
GitHub Actions
      │
      ├── Validate Telegraf config syntax
      ├── Validate Grafana dashboard JSON
      └── SonarCloud code quality scan
```

---

## 💡 Key Learnings

- **Infrastructure as Code** — entire AWS infrastructure defined in Terraform HCL files, reproducible with one command
- **Configuration Management** — Ansible eliminates manual server setup, any new VM is configured automatically
- **Observability** — combination of metrics (Telegraf+InfluxDB) and logs (Promtail+Loki) gives complete system visibility
- **Proactive Alerting** — threshold-based alerts notify admins before users experience issues
- **CI/CD Automation** — every config change is validated automatically before deployment
- **Cloud Deployment** — production-grade monitoring running on AWS EC2 Virtual Machines

---

Made By:-  **Upasana Singh**


---

## 📚 References

- [Telegraf Documentation](https://docs.influxdata.com/telegraf/)
- [InfluxDB 1.x Documentation](https://docs.influxdata.com/influxdb/v1/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Loki Documentation](https://grafana.com/docs/loki/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/)
- [Ansible Documentation](https://docs.ansible.com/)
- [IEEE Benchmark Paper](https://www.researchgate.net/publication/387439552_Development_of_a_System_for_Monitoring_Hardware_Metrics)

---

*InfraWatch — Built with ❤️ for real-world DevOps observability*
