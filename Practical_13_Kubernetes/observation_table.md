# =============================================================================
# observation_table.md
# MLOps Practical-13: Observation Table
# Student: ___________________   Roll No: ___________________   Date: _________
# =============================================================================

# MLOps Practical-13 — Observation Table

## Student Details
| Field        | Value |
|--------------|-------|
| Name         |       |
| Roll Number  |       |
| Date         |       |
| Section      |       |

---

## Observation Table

| # | Activity | Command(s) Used | Observation to Record | Your Observation |
|---|----------|-----------------|----------------------|------------------|
| 1 | **Cluster Startup** | `minikube start --driver=docker` | Node name and Ready status | |
| 2 | **Tool Verification** | `docker --version`, `minikube version`, `kubectl version --client` | Version numbers of all three tools | |
| 3 | **Node Status** | `kubectl get nodes` | Node name, status (should be Ready), roles, age, and Kubernetes version | |
| 4 | **Manifest Files Created** | — | Names of the two YAML files created | `deployment.yaml`, `service.yaml` |
| 5 | **GHCR Image Used** | — | Full image path and tag deployed (no token) | `ghcr.io/<github-username>/student-result-prediction:<IMAGE_TAG>` |
| 6 | **Manifests Applied** | `kubectl apply -f deployment.yaml` / `kubectl apply -f service.yaml` | Kubernetes confirmation messages | |
| 7 | **Initial Deployment** | `kubectl get deployments` | READY value (e.g., 1/1) and Available count | |
| 8 | **Initial Pod Status** | `kubectl get pods` | Pod name, STATUS (Running), READY (1/1), RESTARTS, AGE | |
| 9 | **Service Created** | `kubectl get services` | Service name, TYPE (NodePort), CLUSTER-IP, PORT(S), AGE | |
| 10 | **Service URL** | `minikube service student-result-prediction-service --url` | Local URL shown by Minikube | |
| 11 | **/health Endpoint** | `curl <URL>/health` or browser | JSON response: status, version, model | |
| 12 | **/predict Endpoint** | `POST <URL>/predict` with valid payload | JSON response: prediction (Pass/Fail), request_id, version | |
| 13 | **/metrics Endpoint** | `curl <URL>/metrics` | Prometheus metrics output visible | |
| 14 | **Application Logs** | `kubectl logs <pod-name>` | Example startup log line without sensitive data | |
| 15 | **Scaled to 3 Replicas** | `kubectl scale deployment student-result-prediction --replicas=3` | Number of Ready pods (should be 3/3) | |
| 16 | **Service Backends** | `kubectl get endpointslice -l kubernetes.io/service-name=student-result-prediction-service -o wide` | Number of backend IP addresses in EndpointSlice | |
| 17 | **Pod Deleted (Self-Healing)** | `kubectl delete pod <pod-name>` | Name of the deleted Pod | |
| 18 | **Replacement Pod Created** | `kubectl get pods -w` | Time taken and name of the new replacement Pod | |
| 19 | **Replica Count After Self-Healing** | `kubectl get deployment student-result-prediction` | READY value returns to 3/3 | |
| 20 | **API After Recovery** | `curl <URL>/health` | Service still accessible after pod deletion and recovery | |
| 21 | **Rolling Update Initiated** | `kubectl set image deployment/...` | Old tag and new tag used | Old: `<IMAGE_TAG>`, New: `<NEW_IMAGE_TAG>` |
| 22 | **Rolling Update Status** | `kubectl rollout status deployment/student-result-prediction` | Rollout completion message | |
| 23 | **Rollout History** | `kubectl rollout history deployment/student-result-prediction` | Revision numbers shown (should be ≥ 2) | |
| 24 | **New Image Confirmed** | `kubectl get deployment student-result-prediction -o wide` | Image column showing new tag | |
| 25 | **Rollback Initiated** | `kubectl rollout undo deployment/student-result-prediction` | Rollback confirmation message | |
| 26 | **Active Image After Rollback** | `kubectl get deployment ... -o jsonpath='{.spec.template.spec.containers[0].image}'` | Image reverted to original tag | |
| 27 | **Final Rollout History** | `kubectl rollout history deployment/student-result-prediction` | Revision count and latest revision details | |
| 28 | **Scaled Back to 1** | `kubectl scale deployment student-result-prediction --replicas=1` | Only 1 Pod remaining | |

---

## Summary of Key Findings

| Topic | Key Finding |
|-------|------------|
| Kubernetes vs Docker | Docker packages the app; Kubernetes manages its lifecycle at scale |
| Kubernetes vs Airflow | Airflow orchestrates DAG workflows; Kubernetes orchestrates containers |
| Probes used | Readiness and Liveness both reuse the `/health` endpoint |
| Self-healing | Kubernetes ReplicaSet automatically replaced the deleted Pod |
| Rolling update | Old Pods replaced one-at-a-time; zero downtime maintained |
| Rollback | `kubectl rollout undo` restored the Deployment to the previous revision |

---

## Result

The tested Student Result Prediction Docker image stored in GHCR was deployed
successfully on Kubernetes (Minikube). The application was exposed through a
stable Kubernetes NodePort Service, verified through its `/health`, `/predict`,
and `/metrics` endpoints, scaled to 3 replicas, demonstrated self-healing after
Pod deletion, subjected to a rolling image update, and rolled back to the
previous revision — confirming that Kubernetes provides complete container
orchestration for the ML application.
