# Kubernetes Core Concepts

## Node
- Worker machine (VM or physical server) in a Kubernetes cluster.
- Provides CPU, memory, and storage resources.
- Runs Pods.
- Managed by the Kubernetes control plane.



## Pod
- Smallest deployable unit in Kubernetes.
- Contains one or more containers.
- Containers inside a Pod share:
  - Network namespace (same IP)
  - Storage volumes
- Pods are ephemeral and can be recreated at any time.



## Deployment
- Manages stateless application Pods.
- Ensures desired number of Pod replicas are running.
- Supports:
  - Rolling updates
  - Rollbacks
  - Scaling
  - Self-healing (recreates failed Pods)



## StatefulSet
- Manages stateful applications.
- Provides:
  - Stable Pod names
  - Stable network identities
  - Persistent storage per Pod
  - Ordered deployment and scaling
- Commonly used for:
  - Databases
  - Message queues
  - Distributed systems



## Service
- Provides a stable network endpoint for Pods.
- Load balances traffic across matching Pods.
- Decouples clients from Pod IP changes.

### Types
- **ClusterIP** → Internal access only.
- **NodePort** → Exposes service on a node port.
- **LoadBalancer** → Creates an external load balancer.
- **ExternalName** → Maps service to an external DNS name.



## Ingress
- Manages external HTTP/HTTPS access to Services.
- Routes traffic based on:
  - Hostname
  - URL path
- Allows multiple services to share a single public IP.
- Requires an Ingress Controller (e.g., NGINX).

---

## ConfigMap
- Stores non-sensitive configuration data.
- Separates configuration from application code.
- Can be injected into Pods as:
  - Environment variables
  - Configuration files



## Secret
- Stores sensitive data.
- Examples:
  - Passwords
  - API keys
  - Tokens
  - Certificates
- Can be mounted as files or exposed as environment variables.



## PersistentVolume (PV)
- Cluster-level storage resource.
- Represents actual storage provisioned from:
  - AWS EBS
  - Azure Disk
  - NFS
  - Local storage
- Exists independently of Pods.



## PersistentVolumeClaim (PVC)
- Request for storage by a Pod.
- Specifies:
  - Required size
  - Access mode
  - Storage class
- Kubernetes binds the PVC to a suitable PV.



## Quick Relationship

```text
Node
 └── Pod
      └── Container(s)

Deployment
 └── Manages Pods

StatefulSet
 └── Manages Stateful Pods

Service
 └── Exposes Pods

Ingress
 └── Routes External Traffic → Service

ConfigMap
 └── Non-sensitive Config

Secret
 └── Sensitive Config

PersistentVolume (PV)
 └── Actual Storage

PersistentVolumeClaim (PVC)
 └── Storage Request by Pod
 ```