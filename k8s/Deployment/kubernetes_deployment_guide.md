# Kubernetes Deployment Guide

This guide provides an overview of **Deployments** in Kubernetes, inspired by the **DevOps Directive: Kubernetes Beginner to Pro** curriculum.

---

## 📌 What is a Kubernetes Deployment?

A **Deployment** is a higher-level Kubernetes object that provides declarative updates for **Pods** and **ReplicaSets**. 

While a **ReplicaSet** ensures a specified number of identical Pods are running at any given time, a **Deployment** manages those ReplicaSets to provide seamless application updates, rollbacks, and scaling without manual intervention.

---

## 🏗️ Architecture & Hierarchy

In Kubernetes, application management follows a hierarchical pattern:

```text
+-------------------------------------------------------+
|                     Deployment                        |
|   (Manages rollout strategy, versions, rollbacks)     |
+-------------------------------------------------------+
                           |
                           v
+-------------------------------------------------------+
|                     ReplicaSet                        |
|   (Ensures desired count of Pod instances: e.g., 3)   |
+-------------------------------------------------------+
         /                 |                 \
        v                  v                  v
+---------------+  +---------------+  +---------------+
|     Pod 1     |  |     Pod 2     |  |     Pod 3     |
+---------------+  +---------------+  +---------------+
```

When you update a Deployment configuration (e.g., updating the container image version), Kubernetes creates a **new ReplicaSet** and gradually shifts traffic to it while scaling down the **old ReplicaSet**.

---

## 🔑 Key Features of Deployments

1. **Declarative State Management**: Define the desired state (image version, replica count, environment variables) in a YAML file, and Kubernetes continuously works to achieve that state.
2. **Automated Rolling Updates**: Update applications with zero downtime by replacing instances incrementally.
3. **Rollback Capabilities**: Easily revert to a previous revision if a new release introduces bugs or crashes.
4. **Declarative Scaling**: Adjust replica counts manually or integrate with Horizontal Pod Autoscalers (HPA).
5. **Pause & Resume**: Pause a deployment during complex or multi-stage changes, then resume when ready.

---

## 📄 Manifest Example (`deployment.yaml`)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-web-app
  namespace: default
  labels:
    app.kubernetes.io/name: my-web-app
    app.kubernetes.io/part-of: devops-directive-demo
spec:
  replicas: 3
  revisionHistoryLimit: 10
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1        # Max number of extra pods created during update
      maxUnavailable: 0  # Max number of unavailable pods allowed during update
  selector:
    matchLabels:
      app: my-web-app
  template:
    metadata:
      labels:
        app: my-web-app
    spec:
      containers:
      - name: web-server
        image: nginx:1.25.3
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: "100m"
            memory: "128Mi"
          limits:
            cpu: "500m"
            memory: "256Mi"
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 2
          periodSeconds: 5
```

---

## ⚙️ Core Configuration Fields

| Field | Description |
| :--- | :--- |
| `apiVersion` | `apps/v1` |
| `kind` | `Deployment` |
| `spec.replicas` | The target number of identical Pods to run. |
| `spec.selector` | Label selector used by the Deployment to target its Pods. Must match `spec.template.metadata.labels`. |
| `spec.strategy.type` | Strategy used to replace old Pods with new ones: `RollingUpdate` (default) or `Recreate`. |
| `spec.strategy.rollingUpdate.maxSurge` | How many additional Pods can be created above the desired replica count during an update. |
| `spec.strategy.rollingUpdate.maxUnavailable` | How many Pods can be unavailable during the update process. |
| `spec.template` | The Pod template specification (defines metadata, labels, and container specifications). |
| `spec.revisionHistoryLimit` | The number of old ReplicaSets to retain for rollbacks (default is 10). |

---

## 🔄 Deployment Update Strategies

### 1. RollingUpdate (Default)
Updates Pods in a rolling fashion, creating new Pods while gradually terminating old ones. Ensures zero downtime.

* **`maxSurge: 25%` / `1`**: Up to 25% extra Pods can exist during rollout.
* **`maxUnavailable: 0`**: Ensures 100% capacity is maintained at all times during rollout.

### 2. Recreate
Kills all existing Pods simultaneously before creating new ones. Leads to short downtime but avoids running two different software versions at the same time.

---

## 🛠️ Essential `kubectl` Commands

### Deployment Management
```bash
# Create or update a Deployment
kubectl apply -f deployment.yaml

# List all Deployments
kubectl get deployments

# Get detailed information about a Deployment
kubectl describe deployment my-web-app

# Delete a Deployment (also deletes managed ReplicaSets and Pods)
kubectl delete deployment my-web-app
```

### Scaling
```bash
# Scale Deployment replicas up or down
kubectl scale deployment/my-web-app --replicas=5
```

### Updating Images
```bash
# Update container image directly via CLI
kubectl set image deployment/my-web-app web-server=nginx:1.26.0
```

### Managing Rollouts & History
```bash
# Check status of an ongoing rollout
kubectl rollout status deployment/my-web-app

# View deployment revision history
kubectl rollout history deployment/my-web-app

# Roll back to the previous revision
kubectl rollout undo deployment/my-web-app

# Roll back to a specific revision number
kubectl rollout undo deployment/my-web-app --to-revision=2

# Pause rollout (useful for multi-step edits)
kubectl rollout pause deployment/my-web-app

# Resume rollout
kubectl rollout resume deployment/my-web-app
```

---

## 💡 Best Practices

1. **Always Set Resource Requests & Limits**: Avoid resource starvation and allow the Kubernetes scheduler to place Pods efficiently.
2. **Define Liveness and Readiness Probes**: Ensure zero downtime during rolling updates by letting Kubernetes know when a container is healthy and ready to receive traffic.
3. **Use Declarative Manifests**: Modify YAML files and commit them to version control (GitOps) rather than running imperatively via `kubectl set image`.
4. **Set `maxUnavailable: 0` for High Availability**: Ensures no reduction in active capacity during rolling updates.
5. **Keep Label Selectors Immutable**: Avoid changing the `spec.selector` of an existing Deployment.