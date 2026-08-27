# 📋 Cloud-1: Project Tasks & Evaluation Checklist

This checklist covers all project milestones, technical requirements, cloud configuration, and defense scenarios for **Cloud-1: Automated Deployment of Inception**.

---

## 🚀 Phase 1: Local Inception Stack Readiness
- [x] **Remove all hardcoded values**: Ensure no passwords, usernames, domains, or paths are hardcoded in scripts or Dockerfiles.
- [x] **Comprehensive `.env` file**: Define all database credentials, user accounts, paths, ports, and domains in `srcs/.env`.
- [x] **Environment Validation**: Verify that `srcs/requirements/tools/env-check.sh all` passes with 0 errors.
- [x] **Docker Compose Configuration**: Ensure 1 container = 1 process across all services (`mariadb`, `wordpress`, `nginx`, `redis`, `ftp`, `adminer`, `portainer`, `static-site`).
- [x] **Smoke Tests (`make bonus`)**: Verify WordPress login, HTTPS routing, Redis caching, and persistent volume creation locally.

---

## ☁️ Phase 2: Cloud Infrastructure & AWS Setup
- [ ] **Provision AWS EC2 Instance**:
  - [ ] OS: Ubuntu 22.04 LTS (x86_64).
  - [ ] Instance type: `t2.micro` or `t3.micro` (AWS Free Tier eligible).
  - [ ] Storage: 15–20 GB gp3 EBS volume.
  - [ ] SSH Key: Generate/import SSH key pair (`cloud1_key.pem`).
- [ ] **Configure AWS Security Group (Firewall)**:
  - [ ] Allow Inbound `TCP 22` (SSH) — restricted to your IP / evaluator.
  - [ ] Allow Inbound `TCP 80` (HTTP) — `0.0.0.0/0`.
  - [ ] Allow Inbound `TCP 443` (HTTPS) — `0.0.0.0/0`.
  - [ ] Ensure **NO OTHER PORTS** (such as 3306, 6379, 8081, 8082, 9000, 9001) are open to the internet.
- [ ] **Configure Domain / Dynamic DNS**:
  - [ ] Create a free domain on [DuckDNS](https://www.duckdns.org/) (e.g. `<login>.duckdns.org`).
  - [ ] Point domain A record to the AWS EC2 Public IPv4 address.
- [ ] **Verify Direct SSH Access**:
  - [ ] Test: `ssh -i ~/.ssh/cloud1_key.pem ubuntu@<EC2_PUBLIC_IP>`.

---

## 🤖 Phase 3: Ansible Automation Architecture
- [ ] **Create Directory Structure**:
  - [ ] `ansible/ansible.cfg`
  - [ ] `ansible/inventory.ini`
  - [ ] `ansible/playbook.yml`
  - [ ] `ansible/roles/`
- [ ] **Implement Ansible Roles**:
  - [ ] `roles/common`: Update apt cache, upgrade packages, install `python3`, `curl`, `git`, `ufw`.
  - [ ] `roles/security`:
    - [ ] Configure UFW to default deny incoming, default allow outgoing.
    - [ ] Allow ports `22`, `80`, `443` only.
    - [ ] Enable and start UFW.
  - [ ] `roles/docker`:
    - [ ] Add Docker official GPG key and APT repository.
    - [ ] Install `docker-ce`, `docker-ce-cli`, `containerd.io`, `docker-compose-plugin`.
    - [ ] Add remote user (`ubuntu`) to `docker` group.
    - [ ] Enable and start `docker` systemd service.
  - [ ] `roles/app_deploy`:
    - [ ] Create persistent host directories (`/home/ubuntu/data/...`).
    - [ ] Synchronize / copy project source code to remote server (`/home/ubuntu/cloud-1/`).
    - [ ] Deploy environment configuration (`.env`) safely to remote host.
  - [ ] `roles/service_launch`:
    - [ ] Execute `docker compose up -d --build`.
    - [ ] Wait for services to report healthy.
    - [ ] Check HTTP/HTTPS response from reverse proxy.

---

## 🔒 Phase 4: Subject Requirements & Security Compliance
- [ ] **Port Restriction**: Only 80 (HTTP), 443 (HTTPS), and 22 (SSH) are open to the outside.
- [ ] **Database & Redis Isolation**: Public access to MariaDB (3306) and Redis (6379) is completely blocked.
- [ ] **Reverse Proxy Routing**:
  - [ ] Requests to `http://<domain>` redirect (301/302) to `https://<domain>`.
  - [ ] Requests to `https://<domain>/` route to WordPress.
  - [ ] Requests to `https://<domain>/adminer` (or `/phpmyadmin`) route to the database management tool.
  - [ ] Requests to `https://<domain>/static` route to the static website.
- [ ] **Valid / Working TLS Certificate**:
  - [ ] HTTPS uses TLSv1.2 / TLSv1.3.
- [ ] **Multi-Server Deployment**:
  - [ ] Ansible playbook can deploy to multiple servers listed in `inventory.ini` in parallel.

---

## 🧪 Phase 5: Defense & Evaluation Simulation
- [ ] **1. Fresh Server Deployment Test**:
  - [ ] Destroy/reset the instance or launch a brand-new EC2 instance.
  - [ ] Run `ansible-playbook -i ansible/inventory.ini ansible/playbook.yml`.
  - [ ] Confirm the entire stack deploys hands-free from 0 to 100%.
- [ ] **2. Parallel Deployment Test**:
  - [ ] Add 2 instances to `inventory.ini` and verify parallel deployment succeeds.
- [ ] **3. Security & Port Scan (nmap)**:
  - [ ] Run `nmap -p- <EC2_PUBLIC_IP>`.
  - [ ] Expected open ports: **22, 80, 443 ONLY**.
- [ ] **4. Server Reboot & Data Persistence Test**:
  - [ ] Log into WordPress, write a blog post with an image, and publish it.
  - [ ] Log in as the database administrator in Adminer/phpMyAdmin and verify the database table contents.
  - [ ] Reboot the remote server: `sudo reboot`.
  - [ ] Wait 1 minute and refresh the website.
  - [ ] Verify:
    - [ ] All containers restarted automatically.
    - [ ] The published post, uploaded images, and user accounts are fully intact.
- [ ] **5. URL Redirection Test**:
  - [ ] Run: `curl -I http://<domain>` $\rightarrow$ Must return `301 Moved Permanently` pointing to `https://<domain>`.
  - [ ] Run: `curl -kI https://<domain>` $\rightarrow$ Must return `200 OK`.

---

## 🧹 Phase 6: Git Submission & Hygiene
- [ ] Ensure `.gitignore` is created and prevents committing sensitive files (e.g. `*.pem`, `id_rsa`, `.env` with real production keys).
- [ ] Ensure repository contains all roles, Dockerfiles, docker-compose, configs, and documentation.
- [ ] Verify clean `git status`.
