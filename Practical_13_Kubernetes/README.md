# MLOps Practical-13: Deploy and Scale Student Result Prediction on Kubernetes

**Course:** MLOps (Practical Series)
**Practical:** 13 — Kubernetes Deployment, Scaling, Self-Healing, and Rolling Updates
**Continuation of:** Practical-7 through Practical-12 (Student Result Prediction project)

---

## Aim

Deploy the Dockerized Student Result Prediction API from GitHub Container Registry (GHCR)
on a local Kubernetes (Minikube) cluster, expose it via a NodePort Service, verify all
endpoints, scale to multiple replicas, observe self-healing, perform a rolling update,
and demonstrate rollback.

---

## Folder Structure

```
Practical_13_Kubernetes/
├── deployment.yaml        ← Kubernetes Deployment manifest
├── service.yaml           ← Kubernetes NodePort Service manifest
├── run_practical_13.ps1   ← Step-by-step PowerShell helper script
├── observation_table.md   ← Table to fill during the practical
└── README.md              ← This file
```

---

## Prerequisites

| Requirement | Check Command |
|-------------|--------------|
| Docker Desktop running | `docker --version` |
| Minikube installed | `minikube version` |
| kubectl installed | `kubectl version --client` |
| GHCR image from Practical-11/12 | Visible in your GitHub Packages |

---

## Quick Steps

### 1. Edit `deployment.yaml`
Replace the placeholder image with your actual GHCR image:
```yaml
image: ghcr.io/<github-username>/student-result-prediction:<IMAGE_TAG>
```
For example:
```yaml
image: ghcr.io/deekshitha4024/student-result-prediction:practical-11
```

### 2. Start Minikube
```powershell
minikube start --driver=docker
kubectl get nodes   # Node should be in Ready state
```

### 3. Apply Manifests
```powershell
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl rollout status deployment/student-result-prediction
```

### 4. Get the Service URL
Run in a **new** terminal and keep it open:
```powershell
minikube service student-result-prediction-service --url
```

### 5. Test Endpoints
```powershell
# Health check
Invoke-RestMethod -Uri "http://127.0.0.1:<PORT>/health"

# Prediction
$body = '{"attendance":85,"study_hours":5,"previous_scores":78,"assignments":9,"extracurricular":1}'
Invoke-RestMethod -Uri "http://127.0.0.1:<PORT>/predict" -Method POST -ContentType "application/json" -Body $body

# Swagger UI
Start-Process "http://127.0.0.1:<PORT>/docs"

# Metrics
Invoke-RestMethod -Uri "http://127.0.0.1:<PORT>/metrics"
```

### 6. View Logs
```powershell
kubectl get pods
kubectl logs <pod-name>
kubectl logs -f <pod-name>   # Follow real-time
```

### 7. Scale to 3 Replicas
```powershell
kubectl scale deployment student-result-prediction --replicas=3
kubectl get pods -o wide
kubectl get endpointslice -l kubernetes.io/service-name=student-result-prediction-service -o wide
```

### 8. Self-Healing Demo
```powershell
kubectl get pods                          # Note a pod name
kubectl delete pod <pod-name>             # Delete one pod
kubectl get pods -w                       # Watch it recover (Ctrl+C to stop)
```

### 9. Rolling Update
```powershell
kubectl set image deployment/student-result-prediction `
  student-result-api=ghcr.io/<github-username>/student-result-prediction:<NEW_TAG>
kubectl rollout status deployment/student-result-prediction
kubectl rollout history deployment/student-result-prediction
```

### 10. Rollback
```powershell
kubectl rollout undo deployment/student-result-prediction
kubectl rollout status deployment/student-result-prediction
kubectl get deployment student-result-prediction -o jsonpath='{.spec.template.spec.containers[0].image}'
```

### 11. Scale Back to 1
```powershell
kubectl scale deployment student-result-prediction --replicas=1
kubectl get pods
```

### 12. Cleanup (Optional)
```powershell
kubectl delete -f service.yaml
kubectl delete -f deployment.yaml
minikube stop
```

---

## Kubernetes Objects in This Practical

| Object | Role |
|--------|------|
| **Cluster** | Minikube local Kubernetes environment |
| **Deployment** | Declares desired state; manages ReplicaSets |
| **ReplicaSet** | Maintains the requested number of Pod replicas |
| **Pod** | One running instance of the FastAPI container |
| **Service (NodePort)** | Stable network endpoint in front of the Pods |
| **Readiness Probe** | Gates traffic — uses `/health` |
| **Liveness Probe** | Restarts unhealthy containers — uses `/health` |

---

## Why Kubernetes (Not Just Docker)?

| Capability | Docker alone | Kubernetes |
|------------|-------------|------------|
| Run a container | ✅ | ✅ |
| Desired replica count | ❌ | ✅ |
| Replace failed containers | ❌ | ✅ |
| Stable service endpoint | ❌ | ✅ |
| Rolling updates | ❌ | ✅ |
| Rollback | ❌ | ✅ |

---

## Kubernetes vs Apache Airflow

| | Apache Airflow | Kubernetes |
|--|--------------|------------|
| **Orchestrates** | Workflow tasks (DAGs) | Containers / applications |
| **Answers** | Which ML task runs first/next? | How many app instances run? |
| **Example** | load → preprocess → train → evaluate | Pod → Service → replicas → rolling update |

---

## Private GHCR Package (if applicable)

If your GHCR image is **private**, create a registry Secret **once**:
```powershell
kubectl create secret docker-registry ghcr-secret `
  --docker-server=ghcr.io `
  --docker-username=<github-username> `
  --docker-password=<REGISTRY_READ_TOKEN> `
  --docker-email=<email>

kubectl patch serviceaccount default `
  -p '{"imagePullSecrets":[{"name":"ghcr-secret"}]}'
```
Then uncomment the `imagePullSecrets` section in `deployment.yaml`.

> ⚠️ **NEVER** put a real token in deployment.yaml, screenshots, or source control.

---

## Common Errors & Fixes

| Error | Likely Cause | Fix |
|-------|-------------|-----|
| `ImagePullBackOff` | Wrong tag / private image / no secret | Verify image path; create `ghcr-secret` |
| `CrashLoopBackOff` | App crashes at startup | `kubectl logs <pod>` to inspect the error |
| Pod stays `Pending` | Resource limits / Minikube not started | `kubectl describe pod` → check events |
| Service URL not accessible | Minikube tunnel not active | Re-run `minikube service ... --url` |
| `kubectl top pods` fails | metrics-server not enabled | `minikube addons enable metrics-server` |

---

## Continuity from Previous Practicals

| Practical | Contribution to this Practical |
|-----------|-------------------------------|
| Practical-7 | ML model trained; FastAPI `/predict` endpoint created |
| Practical-8/9 | Docker image built and published to GHCR via GitHub Actions |
| Practical-11 | Structured logging — visible via `kubectl logs` |
| Practical-12 | `/metrics` endpoint — remains available via Kubernetes Service |
| **Practical-13** | Kubernetes deployment, scaling, self-healing, rolling updates, rollback |

---

## Result

The Student Result Prediction application — packaged as a Docker image and stored
in GHCR from earlier practicals — was successfully deployed on Kubernetes, exposed
through a stable Service, scaled, self-healed, rolled out with a new image, and
rolled back, demonstrating complete container orchestration with Kubernetes.
