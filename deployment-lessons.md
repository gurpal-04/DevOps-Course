# Deployment Lessons Learned

## Project Context

Deployed a Flask backend and Express frontend using three architectures:

1. Single EC2 instance
2. Separate EC2 instances
3. Containerized deployment with AWS ECR + ECS + ALB

---

## Key Mistakes and Lessons

### 1. Security Groups Matter as Much as Code

**Issue:** App was not reachable.
**Cause:** Port 80 was not open in the EC2 / ALB security group.
**Lesson:** Always verify inbound rules first.

Checklist:

* HTTP (80)
* HTTPS (443)
* App ports if needed (3000, 5000)
* Restrict sensitive ports

---

### 2. localhost vs Public IP vs Private IP

**Issue:** Frontend could not reach backend.
**Lesson:** Correct URL depends on architecture.

* Same EC2: `http://localhost:5000`
* Separate EC2 same VPC: `http://<private-ip>:5000`
* Separate public hosts: `http://<public-ip>:5000`
* ECS same task: `http://127.0.0.1:5000`

---

### 3. EC2 Restart Does Not Restart Apps Automatically

**Issue:** After instance restart, site returned 502 / apps were down.
**Lesson:** Use process managers.

Use:

* PM2 for Node.js
* systemd services
* supervisor

---

### 4. Public IP Can Change After Stop/Start

**Issue:** Old IP references broke app communication.
**Lesson:** Use Elastic IP or DNS.

---

### 5. Read package.json Before Assuming Commands

**Issue:** Tried `npm run build` but no build script existed.
**Lesson:** Inspect scripts first.

---

### 6. Docker Must Be Installed and Running

**Issues:**

* `docker: command not found`
* `docker.sock no such file`

**Lesson:** Docker Desktop / daemon must be running locally.

---

### 7. CPU Architecture Mismatch Is Real

**Issue:** `exec format error` on ECS.
**Cause:** Built image on Apple Silicon ARM, ran on x86_64 Fargate.
**Fix:** Build with:

```bash
docker buildx build --platform linux/amd64 ...
```

---

### 8. Correct Ports Are Critical

**Issue:** Frontend container mapped to 80 while app listened on 3000.
**Lesson:** Match app listen port with container port mapping.

Examples:

* Frontend Express -> 3000
* Flask backend -> 5000
* ALB listener -> 80

---

### 9. ALB Timeout vs 502 vs 503 Mean Different Things

* **Timeout:** Cannot reach ALB (security group, subnet, listener)
* **502:** Reached proxy, backend app failed
* **503:** No healthy targets

---

### 10. Logs First, Guessing Last

**Best debugging order:**

1. Container / app logs
2. Health checks
3. Network reachability
4. Configuration
5. Code changes

---

## AWS-Specific Lessons

### ECS

* Task definitions must use correct image + ports
* Essential container failure can stop whole task
* Force new deployment after pushing updated images

### ECR

* Tag clearly (`latest`, semantic versions)
* Verify pushed image architecture

### ALB

* Use internet-facing for public apps
* Listener 80 -> target group -> frontend container
* Health check path should return 200

---

## Better Production Practices

* Use Nginx reverse proxy
* Use HTTPS + domain
* Use environment variables
* Add monitoring / alerts
* Use CI/CD for deployments
* Add health endpoints (`/health`)
* Use private networking between services

---

## Reusable Debug Checklist

```text
Is app process running?
Can localhost reach service?
Are ports open?
Is DNS correct?
Are logs showing errors?
Is load balancer healthy?
Did IP change?
Did container image update?
```

---

## Strong Resume Summary

Built and deployed a full-stack Flask + Express application across EC2 and ECS architectures, debugging networking, security groups, Docker architecture issues, ALB health checks, and multi-service communication.

---

## Personal Growth Reminder

Errors are signals.
Infrastructure is part of engineering.
Always build a system model before changing configs.
