# Supabase Deployment on K3s with ArgoCD

This directory contains all the necessary configuration files to deploy Supabase on a K3s cluster using ArgoCD.

## Prerequisites

Before deploying Supabase, ensure you have the following components installed on your K3s cluster:

- ✅ **K3s** cluster (v1.20+)
- ✅ **ArgoCD** for GitOps deployments
- ✅ **Longhorn** for persistent storage
- ✅ **Nginx Ingress Controller**
- ✅ **cert-manager** for SSL/TLS certificates

## File Structure

```
deploy/
├── README.md                    # This file
├── application.yaml             # ArgoCD Application manifest
├── values-k3s.yaml             # Custom values for K3s environment
├── namespace.yaml              # Supabase namespace
├── secrets-example.yaml        # Example secrets (DO NOT use in production)
├── cert-manager-issuer.yaml    # Let's Encrypt ClusterIssuers
└── kustomization.yaml          # Kustomize configuration
```

## Quick Start

### Step 1: Configure Your Domain and Secrets

1. **Update the domain** in [values-k3s.yaml](values-k3s.yaml):
   ```yaml
   kong:
     ingress:
       hosts:
         - host: supabase.yourdomain.com  # Change this
       tls:
         - secretName: supabase-tls
           hosts:
             - supabase.yourdomain.com    # Change this
   ```

2. **Generate secure secrets**:
   ```bash
   # JWT Secret (64 characters)
   openssl rand -base64 64 | tr -d '\n'
   
   # Database password (32 characters)
   openssl rand -base64 32 | tr -d '\n'
   
   # Encryption key (32 characters hex)
   openssl rand -hex 32
   ```

3. **Update secrets** in [values-k3s.yaml](values-k3s.yaml) or create a separate secrets file using your secret management solution.

### Step 2: Configure cert-manager

1. **Update your email** in [cert-manager-issuer.yaml](cert-manager-issuer.yaml):
   ```yaml
   email: admin@yourdomain.com  # Change this
   ```

2. **Apply the ClusterIssuer**:
   ```bash
   kubectl apply -f deploy/cert-manager-issuer.yaml
   ```

### Step 3: Update ArgoCD Application

If you're using a Git repository, update [application.yaml](application.yaml):

```yaml
source:
  repoURL: https://github.com/yourusername/supabase-kubernetes.git  # Change this
  targetRevision: HEAD  # or specific branch/tag
```

### Step 4: Deploy with ArgoCD

**Option A: Using ArgoCD UI**
1. Log into ArgoCD UI
2. Click "New App"
3. Upload or paste the content of `application.yaml`
4. Click "Create"

**Option B: Using kubectl**
```bash
kubectl apply -f deploy/application.yaml
```

**Option C: Using ArgoCD CLI**
```bash
argocd app create supabase \
  --repo https://github.com/yourusername/supabase-kubernetes.git \
  --path charts/supabase \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace supabase \
  --values ../../deploy/values-k3s.yaml \
  --sync-policy automated \
  --auto-prune \
  --self-heal
```

### Step 5: Monitor Deployment

```bash
# Watch ArgoCD application status
argocd app get supabase

# Watch pod status
kubectl get pods -n supabase -w

# Check all resources
kubectl get all -n supabase

# View logs
kubectl logs -n supabase -l app.kubernetes.io/name=supabase-auth
```

## Configuration Details

### Storage Configuration

All persistent volumes are configured to use **Longhorn**:

- **Database (PostgreSQL)**: 20Gi
- **Storage (Files)**: 50Gi
- **Minio (S3)**: 100Gi
- **ImgProxy (Cache)**: 10Gi

You can adjust these sizes in [values-k3s.yaml](values-k3s.yaml).

### Resource Limits

Default resource limits are conservative. Adjust based on your cluster capacity:

```yaml
resources:
  requests:
    memory: "256Mi"
    cpu: "100m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```

### Ingress Configuration

The deployment uses **Nginx Ingress** with **cert-manager** for automatic SSL/TLS:

- Ingress class: `nginx`
- Certificate issuer: `letsencrypt-prod`
- Default domain: `supabase.yourdomain.com` (CHANGE THIS)

## Security Considerations

### 🔐 Secrets Management

**For Production:**

1. **Never commit secrets to Git!** The `secrets-example.yaml` is for reference only.

2. **Use a secrets management solution:**
   - [Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets)
   - [External Secrets Operator](https://external-secrets.io/)
   - [SOPS](https://github.com/mozilla/sops)
   - Kubernetes native secrets with RBAC

3. **Use secretRef in values-k3s.yaml:**
   ```yaml
   secret:
     jwt:
       secretRef: "supabase-jwt-secret"
       secretRefKey:
         anonKey: anonKey
         serviceKey: serviceKey
         secret: secret
   ```

### 🔑 Generate Production Keys

```bash
# Generate JWT keys using Supabase CLI (recommended)
# Install: npm install -g supabase
supabase gen keys

# Or use OpenSSL
openssl rand -base64 64 | tr -d '\n'  # JWT secret
openssl rand -base64 32 | tr -d '\n'  # Passwords
openssl rand -hex 32                   # Encryption keys
```

## DNS Configuration

Point your domain to your K3s cluster ingress:

```bash
# Get your ingress external IP
kubectl get svc -n ingress-nginx

# Add DNS A record:
# supabase.yourdomain.com -> YOUR_INGRESS_IP
```

## Accessing Supabase

After deployment, access Supabase at:

- **API/Studio**: `https://supabase.yourdomain.com`
- **Studio Dashboard**: `https://supabase.yourdomain.com/project/default`
  - Username: From `secret.dashboard.username`
  - Password: From `secret.dashboard.password`

## Troubleshooting

### Pods not starting

```bash
# Check pod status and events
kubectl describe pod -n supabase <pod-name>

# Check logs
kubectl logs -n supabase <pod-name>

# Check PVC status
kubectl get pvc -n supabase
```

### Certificate issues

```bash
# Check cert-manager logs
kubectl logs -n cert-manager -l app=cert-manager

# Check certificate status
kubectl get certificate -n supabase
kubectl describe certificate -n supabase supabase-tls

# Check certificate request
kubectl get certificaterequest -n supabase
```

### Database connection issues

```bash
# Check database pod
kubectl logs -n supabase -l app.kubernetes.io/name=supabase-db

# Connect to database
kubectl exec -it -n supabase supabase-db-0 -- psql -U postgres

# Check database service
kubectl get svc -n supabase -l app.kubernetes.io/name=supabase-db
```

### Ingress not working

```bash
# Check ingress resource
kubectl get ingress -n supabase
kubectl describe ingress -n supabase

# Check nginx ingress logs
kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx
```

## Upgrading

To upgrade Supabase:

1. Update image tags in [values-k3s.yaml](values-k3s.yaml)
2. Commit and push changes to Git
3. ArgoCD will automatically sync (if auto-sync is enabled)

Or manually sync:
```bash
argocd app sync supabase
```

## Backup and Recovery

### Database Backup

```bash
# Create a backup
kubectl exec -n supabase supabase-db-0 -- pg_dump -U postgres postgres > backup.sql

# Restore from backup
kubectl exec -i -n supabase supabase-db-0 -- psql -U postgres postgres < backup.sql
```

### Storage Backup

Use Longhorn's built-in snapshot and backup features:

```bash
# Create snapshot via Longhorn UI
# Or use kubectl
kubectl create -f - <<EOF
apiVersion: longhorn.io/v1beta1
kind: Snapshot
metadata:
  name: supabase-db-snapshot
  namespace: longhorn-system
spec:
  volume: pvc-xxxxx
EOF
```

## Uninstalling

To remove Supabase:

```bash
# Delete ArgoCD application
argocd app delete supabase

# Or using kubectl
kubectl delete -f deploy/application.yaml

# Manually clean up namespace (if needed)
kubectl delete namespace supabase

# Clean up PVCs (WARNING: This deletes all data!)
kubectl delete pvc -n supabase --all
```

## Additional Resources

- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Self-Hosting Guide](https://supabase.com/docs/guides/self-hosting)
- [Helm Chart Documentation](../charts/supabase/README.md)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Longhorn Documentation](https://longhorn.io/docs/)
- [cert-manager Documentation](https://cert-manager.io/docs/)

## Support

This is a community Helm chart and is not officially supported by Supabase. For issues:

1. Check the [troubleshooting section](#troubleshooting)
2. Review [Supabase self-hosting docs](https://supabase.com/docs/guides/self-hosting)
3. Open an issue in this repository

## License

Apache 2.0 License - See [LICENSE](../LICENSE)
