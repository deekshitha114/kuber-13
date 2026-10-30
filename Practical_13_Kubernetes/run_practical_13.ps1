# =============================================================================
# run_practical_13.ps1
# MLOps Practical-13: Deploy and Scale Student Result Prediction on Kubernetes
# =============================================================================
# HOW TO USE:
#   Run each labelled section manually in PowerShell to follow the practical.
#   Do NOT run this entire file at once — each section is a checkpoint.
#
# PREREQUISITES:
#   1. Docker Desktop running
#   2. Minikube installed
#   3. kubectl installed
#   4. Tested Docker image in GHCR from Practical-11 / Practical-12
#
# BEFORE RUNNING:
#   Replace the placeholders below with your actual values:
#     <github-username>  →  your GitHub username (e.g., deekshitha4024)
#     <IMAGE_TAG>        →  your tested image tag (e.g., practical-11, latest)
#     <NEW_IMAGE_TAG>    →  a newer tag for rolling-update (e.g., practical-13)
# =============================================================================

# ─────────────────────────────────────────────────────────────────────────────
# STEP 1 — Verify Tools
# ─────────────────────────────────────────────────────────────────────────────
Write-Host "=== STEP 1: Verify Docker, Minikube, and kubectl ===" -ForegroundColor Cyan
docker --version
minikube version
kubectl version --client

# ─────────────────────────────────────────────────────────────────────────────
# STEP 2 — Start Minikube
# ─────────────────────────────────────────────────────────────────────────────
Write-Host "`n=== STEP 2: Start Minikube cluster ===" -ForegroundColor Cyan
minikube start --driver=docker

# ─────────────────────────────────────────────────────────────────────────────
# STEP 3 — Verify the Cluster
# ─────────────────────────────────────────────────────────────────────────────
Write-Host "`n=== STEP 3: Verify cluster ===" -ForegroundColor Cyan
kubectl cluster-info
kubectl get nodes
kubectl config current-context

# ─────────────────────────────────────────────────────────────────────────────
# STEP 4 — Navigate to Practical-13 folder
# ─────────────────────────────────────────────────────────────────────────────
Write-Host "`n=== STEP 4: Change to Practical_13_Kubernetes folder ===" -ForegroundColor Cyan
# Update this path to match your actual location
Set-Location "C:\Users\deeks\OneDrive\Desktop\13-m\Practical_13_Kubernetes"
Write-Host "Current folder: $(Get-Location)"
Write-Host "Files present:"
Get-ChildItem

# ─────────────────────────────────────────────────────────────────────────────
# STEP 6 — (OPTIONAL) Create GHCR Secret for PRIVATE packages
# Skip if your GHCR package is PUBLIC.
# ─────────────────────────────────────────────────────────────────────────────
Write-Host "`n=== STEP 6 (Optional): Create GHCR Secret ===" -ForegroundColor Yellow
Write-Host "Run the following manually, replacing placeholders:"
Write-Host @"
  kubectl create secret docker-registry ghcr-secret `
    --docker-server=ghcr.io `
    --docker-username=<github-username> `
    --docker-password=<REGISTRY_READ_TOKEN> `
    --docker-email=<email>

  kubectl patch serviceaccount default `
    -p '{"imagePullSecrets":[{"name":"ghcr-secret"}]}'

  kubectl get secret ghcr-secret
"@

# ─────────────────────────────────────────────────────────────────────────────
# STEP 9 — Apply Kubernetes Manifests
# Edit deployment.yaml to replace <github-username> and <IMAGE_TAG> first!
# ─────────────────────────────────────────────────────────────────────────────
Write-Host "`n=== STEP 9: Apply manifests ===" -ForegroundColor Cyan
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

# ─────────────────────────────────────────────────────────────────────────────
# STEP 10 — Wait for Deployment to be Ready
# ─────────────────────────────────────────────────────────────────────────────
Write-Host "`n=== STEP 10: Check rollout status ===" -ForegroundColor Cyan
kubectl rollout status deployment/student-result-prediction
kubectl get deployments
kubectl get pods
kubectl get services

# ─────────────────────────────────────────────────────────────────────────────
# STEP 11 — Inspect Deployment Details
# ─────────────────────────────────────────────────────────────────────────────
Write-Host "`n=== STEP 11: Describe deployment and pods ===" -ForegroundColor Cyan
kubectl describe deployment student-result-prediction
kubectl get pods -o wide

# ─────────────────────────────────────────────────────────────────────────────
# STEP 12 — Get the Service URL
# This command may keep a tunnel open — run in a SEPARATE terminal window.
# ─────────────────────────────────────────────────────────────────────────────
Write-Host "`n=== STEP 12: Get service URL (run in a new terminal) ===" -ForegroundColor Cyan
Write-Host "Run this command in a NEW terminal and keep it open:"
Write-Host "  minikube service student-result-prediction-service --url"

# ─────────────────────────────────────────────────────────────────────────────
# STEP 13 — Test Endpoints (replace <SERVICE_URL> with output from Step 12)
# ─────────────────────────────────────────────────────────────────────────────
Write-Host "`n=== STEP 13: Test endpoints ===" -ForegroundColor Cyan
Write-Host "Replace <SERVICE_URL> with the URL from minikube service command."
Write-Host ""
Write-Host "Health check:"
Write-Host "  Invoke-RestMethod -Uri '<SERVICE_URL>/health'"
Write-Host ""
Write-Host "Prediction test:"
$predictPayload = @{
    attendance      = 85.0
    study_hours     = 5.0
    previous_scores = 78.0
    assignments     = 9
    extracurricular = 1
} | ConvertTo-Json
Write-Host "  Payload: $predictPayload"
Write-Host "  Invoke-RestMethod -Uri '<SERVICE_URL>/predict' -Method POST -ContentType 'application/json' -Body '$predictPayload'"
Write-Host ""
Write-Host "Metrics check:"
Write-Host "  Invoke-RestMethod -Uri '<SERVICE_URL>/metrics'"
Write-Host ""
Write-Host "Swagger docs: open <SERVICE_URL>/docs in your browser"

# ─────────────────────────────────────────────────────────────────────────────
# STEP 14 — Inspect Application Logs
# ─────────────────────────────────────────────────────────────────────────────
Write-Host "`n=== STEP 14: View application logs ===" -ForegroundColor Cyan
Write-Host "Get the pod name first:"
kubectl get pods
Write-Host ""
Write-Host "Then run:"
Write-Host "  kubectl logs <pod-name>"
Write-Host "  kubectl logs -f <pod-name>   # Follow real-time logs"

# ─────────────────────────────────────────────────────────────────────────────
# STEP 15 — Scale to 3 Replicas
# ─────────────────────────────────────────────────────────────────────────────
Write-Host "`n=== STEP 15: Scale to 3 replicas ===" -ForegroundColor Cyan
kubectl scale deployment student-result-prediction --replicas=3
Start-Sleep -Seconds 5
kubectl get deployment student-result-prediction
kubectl get pods -o wide

# ─────────────────────────────────────────────────────────────────────────────
# STEP 16 — Verify Service Backends (EndpointSlice)
# ─────────────────────────────────────────────────────────────────────────────
Write-Host "`n=== STEP 16: Verify service backends ===" -ForegroundColor Cyan
kubectl get endpointslice -l kubernetes.io/service-name=student-result-prediction-service -o wide

# ─────────────────────────────────────────────────────────────────────────────
# STEP 17 — Self-Healing Demo
# ─────────────────────────────────────────────────────────────────────────────
Write-Host "`n=== STEP 17: Self-healing demonstration ===" -ForegroundColor Cyan
Write-Host "Current pods:"
kubectl get pods
Write-Host ""
Write-Host "Copy one pod name from above, then run:"
Write-Host "  kubectl delete pod <one-pod-name>"
Write-Host "  kubectl get pods -w    # Watch replacement (Ctrl+C to stop)"

# ─────────────────────────────────────────────────────────────────────────────
# STEP 18 — Verify After Self-Healing
# ─────────────────────────────────────────────────────────────────────────────
Write-Host "`n=== STEP 18: Verify API after pod recovery ===" -ForegroundColor Cyan
Write-Host "Test /health and /predict again through the same Service URL."
kubectl get pods

# ─────────────────────────────────────────────────────────────────────────────
# STEP 20 — Rolling Update
# Replace <NEW_IMAGE_TAG> with an actual newer tag from GHCR.
# ─────────────────────────────────────────────────────────────────────────────
Write-Host "`n=== STEP 20: Rolling update ===" -ForegroundColor Cyan
Write-Host "Replace <github-username> and <NEW_IMAGE_TAG> in the command below:"
Write-Host "  kubectl set image deployment/student-result-prediction \"
Write-Host "    student-result-api=ghcr.io/<github-username>/student-result-prediction:<NEW_IMAGE_TAG>"
Write-Host "  kubectl rollout status deployment/student-result-prediction"
Write-Host "  kubectl get pods -w    # Watch rolling update in another terminal"

# ─────────────────────────────────────────────────────────────────────────────
# STEP 21 — Verify New Image and Rollout History
# ─────────────────────────────────────────────────────────────────────────────
Write-Host "`n=== STEP 21: Verify rollout and history ===" -ForegroundColor Cyan
kubectl get deployment student-result-prediction -o wide
kubectl rollout history deployment/student-result-prediction
kubectl get pods -o wide

# ─────────────────────────────────────────────────────────────────────────────
# STEP 22 — Rollback to Previous Revision
# ─────────────────────────────────────────────────────────────────────────────
Write-Host "`n=== STEP 22: Rollback to previous revision ===" -ForegroundColor Cyan
kubectl rollout undo deployment/student-result-prediction
kubectl rollout status deployment/student-result-prediction
kubectl rollout history deployment/student-result-prediction
Write-Host ""
Write-Host "Active image after rollback:"
kubectl get deployment student-result-prediction -o jsonpath='{.spec.template.spec.containers[0].image}'
Write-Host ""

# ─────────────────────────────────────────────────────────────────────────────
# STEP 23 — Scale Back to 1 Replica
# ─────────────────────────────────────────────────────────────────────────────
Write-Host "`n=== STEP 23: Scale back to 1 replica ===" -ForegroundColor Cyan
kubectl scale deployment student-result-prediction --replicas=1
Start-Sleep -Seconds 3
kubectl get pods

# ─────────────────────────────────────────────────────────────────────────────
# STEP 24 — Optional: Enable Metrics Server and Check Resource Usage
# ─────────────────────────────────────────────────────────────────────────────
Write-Host "`n=== STEP 24 (Optional): Enable metrics-server ===" -ForegroundColor Yellow
Write-Host "  minikube addons enable metrics-server"
Write-Host "  # Wait ~60 seconds, then:"
Write-Host "  kubectl top pods"

# ─────────────────────────────────────────────────────────────────────────────
# STEP 26 — Cleanup (Optional)
# ─────────────────────────────────────────────────────────────────────────────
Write-Host "`n=== STEP 26 (Optional Cleanup): ===" -ForegroundColor Yellow
Write-Host "Remove Kubernetes resources:"
Write-Host "  kubectl delete -f service.yaml"
Write-Host "  kubectl delete -f deployment.yaml"
Write-Host "  kubectl delete secret ghcr-secret   # Only if created"
Write-Host ""
Write-Host "Stop Minikube (preserves the cluster):"
Write-Host "  minikube stop"
Write-Host ""
Write-Host "Delete entire Minikube cluster (destructive):"
Write-Host "  minikube delete"

Write-Host "`n=== Practical-13 Script Complete ===" -ForegroundColor Green
