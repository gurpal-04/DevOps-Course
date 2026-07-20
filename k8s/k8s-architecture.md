# Kubernetes Architecture

## Control Plane (Master Node)
- One or more control plane nodes
- The Control Plane manages and controls the entire Kubernetes cluster.

## Agents 
1. ### API Server
- Entry point for all Kubernetes operations.
- Receives requests from:
  - kubectl
  - UI dashboards
  - Internal cluster components
- Validates and processes requests.
- Communicates with etcd to store and retrieve cluster state.

2. ### Scheduler
- Decides which Worker Node should run a newly created Pod.
- Considers:
  - Available resources (CPU, Memory)
  - Node affinity/anti-affinity
  - Taints and tolerations
  - Resource constraints

3. ### Controller Manager
- Runs controllers that maintain the desired state of the cluster.
- Examples:
  - Deployment Controller
  - ReplicaSet Controller
  - Node Controller
  - Job Controller
- Continuously monitors the cluster and takes corrective actions when needed.

4. ### etcd
- Distributed key-value database.
- Stores the entire cluster state.
- Contains:
  - Pods
  - Nodes
  - Services
  - ConfigMaps
  - Secrets
- Acts as the single source of truth for Kubernetes.
- etcd is a distributed, strongly consistent key-value database that stores the entire  Kubernetes cluster state.
- Only the API Server can directly communicate with etcd.
- Uses an append-only storage model; old data is periodically compacted.
- etcdctl is the CLI tool used for backup (snapshot) and restore operations.
- Supports High Availability (HA) using the Raft Consensus Algorithm, which provides automatic leader election and fault tolerance.
- Can be deployed as:
  - Stacked etcd – runs on the same control plane node.
  - External etcd – runs on dedicated servers (recommended for production).
- Stores Kubernetes resources such as Pods, Nodes, Deployments, ConfigMaps, Secrets, Services, and cluster configuration.

---

## Worker Node
- One or more worker nodes (optional, but recommended).
- Worker Nodes run the actual application workloads.

1. ### Kubelet
- Node agent running on every Worker Node.
- Communicates with the API Server.
- Ensures Pods are running as defined.
- Monitors container health and reports status.

2. ### Kube-Proxy
- Handles networking for Services.
- Maintains network rules on the node.
- Enables communication between Pods and Services.
- Performs load balancing across Pod replicas.

3. ### Container Runtime
- Software responsible for running containers.
- Pulls container images.
- Starts and stops containers.
- Examples:
  - containerd
  - CRI-O
  - Docker (via CRI compatibility)

---

## Architecture Flow

```text
                 kubectl
                     │
                     ▼
              API Server
                     │
      ┌──────────────┼──────────────┐
      ▼              ▼              ▼
 Scheduler    Controller Manager   etcd
      │
      ▼
 ┌───────────────┐
 │ Worker Node 1 │
 ├───────────────┤
 │ Kubelet       │
 │ Kube-Proxy    │
 │ Containerd    │
 │ Pod(s)        │
 └───────────────┘

 ┌───────────────┐
 │ Worker Node 2 │
 ├───────────────┤
 │ Kubelet       │
 │ Kube-Proxy    │
 │ Containerd    │
 │ Pod(s)        │
 └───────────────┘
```

## One-Line Interview Definitions

- **API Server** → Entry point of the Kubernetes cluster.
- **Scheduler** → Assigns Pods to Worker Nodes.
- **Controller Manager** → Maintains desired cluster state.
- **etcd** → Stores cluster configuration and state.
- **Kubelet** → Ensures containers run correctly on a node.
- **Kube-Proxy** → Handles Service networking and load balancing.
- **Container Runtime** → Runs containers on the node.