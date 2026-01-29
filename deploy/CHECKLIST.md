# Pre-Deployment Checklist for Supabase on K3s

## Prerequisites Verification

### 1. Cluster Components
- [ ] K3s cluster is running (v1.20+)
- [ ] ArgoCD is installed and accessible
- [ ] Longhorn is installed and healthy
  ```bash
  kubectl get pods -n longhorn-system
  kubectl get storageclass longhorn
  ```
- [ ] Nginx Ingress Controller is running
  ```bash
  kubectl get pods -n ingress-nginx
  kubectl get svc -n ingress-nginx
  ```
- [ ] cert-manager is installed
  ```bash
  kubectl get pods -n cert-manager
  ```

### 2. Domain and DNS
- [ ] Domain name registered: `supabase.yourdomain.com`
- [ ] DNS A record pointing to cluster ingress IP
  ```bash
  # Get ingress IP
  kubectl get svc -n ingress-nginx ingress-nginx-controller
  ```
- [ ] Domain resolution verified
  ```bash
  nslookup supabase.yourdomain.com
  dig supabase.yourdomain.com
  ```

### 3. Secrets Configuration
- [ ] Generated secure JWT secrets
  ```bash
  # Run the generator
  ./deploy/generate-secrets.sh
  # or
  pwsh ./deploy/generate-secrets.ps1
  ```
- [ ] Updated `secret.jwt.secret` in values-k3s.yaml
- [ ] Updated `secret.jwt.anonKey` in values-k3s.yaml
- [ ] Updated `secret.jwt.serviceKey` in values-k3s.yaml
- [ ] Updated `secret.db.password` in values-k3s.yaml
- [ ] Updated `secret.analytics.publicAccessToken` in values-k3s.yaml
- [ ] Updated `secret.analytics.privateAccessToken` in values-k3s.yaml
- [ ] Updated `secret.dashboard.password` in values-k3s.yaml
- [ ] Updated `secret.realtime.secretKeyBase` in values-k3s.yaml
- [ ] Updated `secret.meta.cryptoKey` in values-k3s.yaml
- [ ] SMTP credentials configured (if using email)

### 4. Configuration Updates
- [ ] Updated domain in `values-k3s.yaml`:
  - `studio.environment.SUPABASE_PUBLIC_URL`
  - `auth.environment.API_EXTERNAL_URL`
  - `auth.environment.GOTRUE_SITE_URL`
  - `kong.ingress.hosts[0].host`
  - `kong.ingress.tls[0].hosts[0]`
- [ ] Updated email in `cert-manager-issuer.yaml`
- [ ] Updated ArgoCD repo URL in `application.yaml`
- [ ] Reviewed resource limits based on cluster capacity
- [ ] Reviewed storage sizes (default: db=20Gi, storage=50Gi, minio=100Gi)

### 5. cert-manager Configuration
- [ ] ClusterIssuer created
  ```bash
  kubectl apply -f deploy/cert-manager-issuer.yaml
  kubectl get clusterissuer
  ```
- [ ] Test certificate creation (optional)
  ```bash
  kubectl get certificaterequest -A
  ```

### 6. Git Repository (if using GitOps)
- [ ] Code pushed to Git repository
- [ ] Repository accessible from cluster
- [ ] Branch/tag specified in `application.yaml`
- [ ] Secrets NOT committed to Git

## Deployment Steps

### 1. Create Namespace
```bash
kubectl apply -f deploy/namespace.yaml
kubectl get namespace supabase
```

### 2. Apply cert-manager ClusterIssuers
```bash
kubectl apply -f deploy/cert-manager-issuer.yaml
kubectl get clusterissuer letsencrypt-prod
```

### 3. Deploy via ArgoCD

#### Option A: Using ArgoCD UI
- [ ] Login to ArgoCD UI
- [ ] Create new application
- [ ] Upload `deploy/application.yaml`
- [ ] Sync application

#### Option B: Using kubectl
```bash
kubectl apply -f deploy/application.yaml
```

#### Option C: Using ArgoCD CLI
```bash
argocd app create supabase \
  --repo https://github.com/yourusername/supabase-kubernetes.git \
  --path charts/supabase \
  --dest-namespace supabase \
  --values ../../deploy/values-k3s.yaml \
  --sync-policy automated
```

### 4. Monitor Deployment
```bash
# Watch application sync
argocd app get supabase

# Watch pods
kubectl get pods -n supabase -w

# Check all resources
kubectl get all -n supabase

# Check PVCs
kubectl get pvc -n supabase
```

## Post-Deployment Verification

### 1. Pod Status
- [ ] All pods are running
  ```bash
  kubectl get pods -n supabase
  ```
- [ ] No CrashLoopBackOff or Error states
- [ ] Check pod logs if any issues
  ```bash
  kubectl logs -n supabase <pod-name>
  ```

### 2. Services
- [ ] All services created
  ```bash
  kubectl get svc -n supabase
  ```

### 3. Persistent Volumes
- [ ] All PVCs bound
  ```bash
  kubectl get pvc -n supabase
  ```
- [ ] Longhorn volumes created
  ```bash
  kubectl get volumes -n longhorn-system
  ```

### 4. Ingress and Certificates
- [ ] Ingress created
  ```bash
  kubectl get ingress -n supabase
  ```
- [ ] Certificate issued
  ```bash
  kubectl get certificate -n supabase
  kubectl describe certificate supabase-tls -n supabase
  ```
- [ ] Certificate status is "Ready"
- [ ] HTTPS accessible: `https://supabase.yourdomain.com`

### 5. Application Access
- [ ] Studio UI accessible
  - URL: `https://supabase.yourdomain.com`
- [ ] Can login to Studio dashboard
  - Username: from `secret.dashboard.username`
  - Password: from `secret.dashboard.password`
- [ ] API endpoints responding
  ```bash
  curl -k https://supabase.yourdomain.com/rest/v1/
  ```

### 6. Database
- [ ] Can connect to database
  ```bash
  kubectl exec -it -n supabase supabase-db-0 -- psql -U postgres
  ```
- [ ] Database initialized properly
  ```sql
  \l  -- list databases
  \dt -- list tables
  ```

### 7. Storage
- [ ] Minio accessible internally
- [ ] Storage service running
- [ ] Can upload files via Studio

## Troubleshooting Checklist

If deployment fails, check:

- [ ] ArgoCD application status
  ```bash
  argocd app get supabase
  ```
- [ ] Pod events
  ```bash
  kubectl describe pod -n supabase <pod-name>
  ```
- [ ] Pod logs
  ```bash
  kubectl logs -n supabase <pod-name>
  ```
- [ ] PVC status
  ```bash
  kubectl describe pvc -n supabase
  ```
- [ ] Certificate status
  ```bash
  kubectl describe certificate -n supabase supabase-tls
  kubectl get certificaterequest -n supabase
  ```
- [ ] Ingress configuration
  ```bash
  kubectl describe ingress -n supabase
  ```
- [ ] Service endpoints
  ```bash
  kubectl get endpoints -n supabase
  ```

## Security Checklist

- [ ] All default passwords changed
- [ ] Secrets stored securely (not in Git)
- [ ] TLS/SSL enabled and working
- [ ] Network policies configured (if needed)
- [ ] RBAC properly configured
- [ ] Regular backup schedule planned
- [ ] Monitoring and alerting set up

## Maintenance

- [ ] Backup strategy documented
- [ ] Update procedure documented
- [ ] Rollback procedure tested
- [ ] Monitoring dashboard configured
- [ ] Log aggregation configured

## Notes

Add any environment-specific notes here:

```
Cluster: 
IP Address: 
Domain: 
Deployment Date: 
Deployed By: 
```

---

**Status**: [ ] Pre-deployment | [ ] Deploying | [ ] Deployed | [ ] Production

**Last Updated**: ___________
