# ☁️ Cloud-1: Automated Deployment of Inception

[![Docker](https://img.shields.io/badge/Docker-24.0+-blue.svg?logo=docker&logoColor=white)](https://www.docker.com/)
[![Ansible](https://img.shields.io/badge/Ansible-2.15+-EE0000.svg?logo=ansible&logoColor=white)](https://www.ansible.com/)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04%20LTS-E95420.svg?logo=ubuntu&logoColor=white)](https://ubuntu.com/)
[![AWS](https://img.shields.io/badge/AWS-EC2%20Free%20Tier-FF9900.svg?logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)
[![Security](https://img.shields.io/badge/Security-UFW%20%7C%20TLS%201.3-success.svg)](#security-and-firewall)

Automated, idempotent, multi-host cloud deployment of an **Inception** infrastructure (WordPress, MariaDB, Nginx, Redis, Adminer, FTP, Portainer, and Static Website) onto remote cloud instances using **Ansible** and **Docker Compose**.

---

## 📌 Table of Contents
- [Architecture](#-architecture)
- [Project Structure](#-project-structure)
- [Requirements & Features](#-requirements--features)
- [Prerequisites](#-prerequisites)
- [Quickstart Guide](#-quickstart-guide)
- [Services & Routing](#-services--routing)
- [Security & Firewall](#-security--firewall)
- [Testing & Verification](#-testing--verification)
- [Author](#-author)

---

## 🏛️ Architecture

```
                                  [ INTERNET ]
                                       |
                                       | HTTPS (443) / HTTP (80)
                                       v
                     +-----------------------------------+
                     |      AWS Security Group / UFW     |
                     |     Allowed: 22, 80, 443 ONLY     |
                     +-----------------------------------+
                                       |
                                       v
                     +-----------------------------------+
                     |   NGINX Reverse Proxy & TLS (443) |
                     +-----------------+-----------------+
                                       |
          +----------------------------+----------------------------+
          |                            |                            |
          v                            v                            v
  [ WordPress (FPM) ]             [ Adminer ]             [ Static Website ]
          |
     +----+----+
     |         |
     v         v
[ MariaDB ] [ Redis ]
```

---

## 📂 Project Structure

```text
.
├── Makefile                     # Local build, test, and smoke test orchestrator
├── README.md                    # Project documentation
├── CHECKLIST.md                 # Evaluation and defense checklist
├── ansible/                     # Automated Deployment Infrastructure
│   ├── ansible.cfg              # Ansible configuration
│   ├── inventory.ini            # Target hosts and credentials
│   ├── playbook.yml             # Main deployment playbook
│   └── roles/
│       ├── common/              # System packages, Python3, and utilities
│       ├── security/            # UFW firewall (22, 80, 443 only)
│       ├── docker/              # Docker Engine & Compose plugin installation
│       ├── app_deploy/          # App code transfer, .env setup, data dirs
│       └── service_launch/      # Stack bootstrap and health check verification
└── srcs/                        # Inception Container Stack
    ├── docker-compose.yml       # Multi-container service definitions
    ├── .env                     # Environment variables & secrets (templated)
    └── requirements/
        ├── mariadb/             # MariaDB 10.x container & init script
        ├── wordpress/           # WordPress + PHP-FPM + WP-CLI + Redis extension
        ├── nginx/               # Nginx TLS termination & reverse proxy
        ├── tools/               # env-check.sh and validation tools
        └── bonus/
            ├── redis/           # Redis cache container
            ├── ftp/             # vsftpd FTP server for WP files
            ├── adminer/         # Database management web interface
            ├── portainer/       # Container management UI
            └── static-site/     # Static HTML/CSS showcase site
```

---

## 🌟 Requirements & Features

- **Full Automation**: 100% automated deployment using Ansible across fresh Ubuntu 22.04 LTS instances.
- **Microservices Isolation**: 1 process per container connected through dedicated internal Docker networks.
- **Port Restriction**: Only ports **22 (SSH)**, **80 (HTTP)**, and **443 (HTTPS)** are exposed to the public internet; internal service ports (3306, 6379, 9000, etc.) are strictly isolated.
- **Fault Tolerance & Auto-Restart**: Stack configured with `restart: unless-stopped` and systemd persistence.
- **Data Persistence**: MariaDB databases, WordPress uploads, Redis cache, and Portainer data are mounted to host storage volumes (`/data`).
- **Parallel Deployment**: Ansible inventory supports deploying to single or multiple remote servers concurrently.
- **No Hardcoded Secrets**: All passwords, usernames, ports, domains, and data directories are dynamically injected from `.env`.

---

## ⚙️ Prerequisites

1. **Remote Cloud Server**: An AWS EC2 instance (or any VPS) running **Ubuntu 22.04 LTS** with SSH access.
2. **Local Machine Requirements**:
   - `python3` (v3.8+)
   - `ansible` (v2.14+)
   - `ssh` client with your cloud private key (`.pem`)

---

## 🚀 Quickstart Guide

### 1. Clone the Repository
```bash
git clone https://github.com/your-username/cloud-1.git
cd cloud-1
```

### 2. Configure Ansible Inventory
Edit `ansible/inventory.ini` with your remote server IP and SSH key:
```ini
[webservers]
server1 ansible_host=YOUR_EC2_PUBLIC_IP ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/your-key.pem

[webservers:vars]
ansible_python_interpreter=/usr/bin/python3
```

### 3. Configure Environment Variables
Copy and customize the `.env` configuration in `srcs/.env`:
```bash
DOMAIN_NAME=yourdomain.duckdns.org
DATA_PATH=/home/ubuntu/data
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
MYSQL_PASSWORD=SecurePassword123!
MYSQL_ROOT_PASSWORD=SecureRootPassword123!
WP_ADMIN_USER=admin_user
WP_ADMIN_PASS=AdminPassword123!
WP_ADMIN_EMAIL=admin@yourdomain.duckdns.org
WP_USER_USER=editor_user
WP_USER_PASS=EditorPassword123!
WP_USER_EMAIL=editor@yourdomain.duckdns.org
REDIS_PASSWORD=RedisSecret123!
FTP_USER=ftpuser
FTP_PASSWORD=FtpSecret123!
```

### 4. Deploy with Ansible
Execute the automated playbook:
```bash
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml
```

---

## 🌐 Services & Routing

| Service | Protocol / Port | External Access Path | Internal Port | Description |
| :--- | :--- | :--- | :--- | :--- |
| **Nginx** | HTTPS / 443 | `https://<domain>/` | 443 | TLS Gateway & Reverse Proxy |
| **WordPress** | FastCGI / PHP | `https://<domain>/` | 9000 | WordPress Blog (PHP 7.4-FPM) |
| **Adminer** | HTTP (Internal) | `https://<domain>/adminer` | 8082 | Database Admin Interface |
| **Static Site** | HTTP (Internal) | `https://<domain>/static` | 8081 | Static HTML5/CSS3 Showcase |
| **MariaDB** | TCP (Internal) | *Internal Network Only* | 3306 | SQL Relational Database |
| **Redis** | TCP (Internal) | *Internal Network Only* | 6379 | In-memory Object Cache |
| **Portainer** | HTTP (Internal) | *Internal Network Only* | 9000 | Container Monitoring |
| **FTP** | TCP | Port 21 (Protected) | 21 | vsftpd File Server |

---

## 🔒 Security and Firewall

- **Firewall Policy**: Managed via `ufw` on the host and AWS Security Groups:
  - `ALLOW Inbound`: `22/tcp`, `80/tcp`, `443/tcp`.
  - `DEFAULT Inbound`: `DROP / DENY`.
- **Database & Cache Protection**: MariaDB and Redis do not bind to host public interfaces; they communicate strictly over the internal Docker bridge network (`inception`).
- **Encrypted Traffic**: Enforced TLS 1.2 and TLS 1.3 encryption with automatic redirection from `http://` (port 80) to `https://` (port 443).

---

## 🧪 Testing & Verification

Run local verification and smoke tests using the `Makefile`:

```bash
# Validate environment variable integrity
bash srcs/requirements/tools/env-check.sh all

# Build all container images locally
make build

# Start the full stack
make up

# Run automated HTTP/HTTPS and authentication smoke tests
make bonus

# Check container status
make ps

# View real-time container logs
make logs

# Teardown containers and clean volumes
make fclean
```

---

## 👤 Author
- **GitHub**: [@aelasefa](https://github.com/aelasefa)
- **42 Intra**: `ayelasef / aelasefa`
