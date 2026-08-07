# CI/CD Deployment Guide

## Overview

This project uses **Jenkins** for CI/CD and **Docker Compose** to deploy services to an AWS EC2 instance.

Jenkins is responsible for:
- Checking out the latest code from GitHub
- Connecting to the EC2 instance over SSH
- Pulling the latest changes
- Rebuilding and restarting only the required service

---

# Architecture

```text
                GitHub Repository
                        │
                        ▼
              Jenkins (Local Machine)
                        │
                    SSH Connection
                        ▼
                 AWS EC2 Instance
                        │
                  git pull origin main
                        │
      docker compose up -d --build --no-deps
                        │
          ┌─────────────┴─────────────┐
          ▼                           ▼
      Frontend                    Backend
```

---

# Infrastructure

## AWS EC2

- Ubuntu Server
- Git installed
- Docker installed
- Docker Compose installed

Project directory:

```text
~/DevOps-Course/Docker
```

## Jenkins

Jenkins runs locally inside Docker and performs the deployment pipeline.

Responsibilities:

- Checkout repository
- Connect to EC2 over SSH
- Pull latest code
- Deploy the selected service

---

# Deployment Workflow

## Backend Deployment

The backend pipeline performs:

1. Checkout the latest code.
2. SSH into the EC2 instance.
3. Navigate to the project directory.
4. Pull the latest changes.
5. Rebuild the backend image.
6. Restart the backend container.

Deployment command:

```bash
cd ~/DevOps-Course/Docker
git pull origin main
docker compose up -d --build --no-deps backend
```

---

## Frontend Deployment

The frontend pipeline performs:

1. Checkout the latest code.
2. SSH into the EC2 instance.
3. Navigate to the project directory.
4. Pull the latest changes.
5. Rebuild the frontend image.
6. Restart the frontend container.

Deployment command:

```bash
cd ~/DevOps-Course/Docker
git pull origin main
docker compose up -d --build --no-deps frontend
```

---

# Why `--no-deps`?

Using:

```bash
docker compose up -d --build --no-deps <service>
```

ensures only the specified service is rebuilt and restarted.

Example:

```bash
docker compose up -d --build --no-deps frontend
```

Result:

- ✅ Frontend is rebuilt and restarted.
- ✅ Backend continues running without interruption.

---

# Jenkins Configuration

## Credentials

### GitHub

Used by Jenkins to access the repository.

### EC2 SSH

Credential Type:

```text
SSH Username with private key
```

Username:

```text
ubuntu
```

Authentication:

Private SSH key stored securely in Jenkins Credentials.

---

# Pipeline Stages

Each pipeline consists of the following stages:

### 1. Checkout

Retrieve the latest source code from GitHub.

### 2. Deploy

SSH into the EC2 instance and execute the deployment commands.

---

# Verifying Deployment

List running containers:

```bash
docker ps
```

View logs:

```bash
docker compose logs
```

View logs for a specific service:

```bash
docker compose logs frontend

docker compose logs backend
```

---

# Accessing the Application

Frontend:

```text
http://<EC2_PUBLIC_IP>:3000
```

Backend:

```text
http://<EC2_PUBLIC_IP>:5000
```



# CI/CD Flow

```text
             Developer
                 │
             git push
                 │
                 ▼
             GitHub Repo
                 │
                 ▼
              Jenkins
                 │
          Checkout Source
                 │
                 ▼
          SSH into EC2
                 │
                 ▼
        git pull origin main
                 │
                 ▼
docker compose up -d --build --no-deps
                 │
                 ▼
      Updated Docker Container
```

---

# Current Status

- ✅ EC2 configured
- ✅ Docker installed
- ✅ Docker Compose configured
- ✅ Git installed
- ✅ Jenkins running locally
- ✅ Jenkins connected to EC2 via SSH
- ✅ Backend deployment pipeline configured
- ✅ Frontend deployment pipeline configured
```