# Quick Start Guide - Deploying Supabase on K3s

**Domain:** api.credaction.com  
**Namespace:** spalce-credaction-supabase

## Prerequisites ✅
- K3s cluster running
- ArgoCD installed
- Longhorn storage
- Nginx Ingress
- cert-manager with ClusterIssuer already configured

## Step 1: Generate Secrets

Run the secret generator:
```powershell
pwsh .\deploy\generate-secrets.ps1
```

## Step 2: Update Secrets in values-k3s.yaml

Edit [values-k3s.yaml](values-k3s.yaml) and replace ALL the `CHANGE-THIS` values with the secrets you generated:

```yaml
secret:
  jwt:
    secret: "your-generated-jwt-secret"
  db:
    password: "your-generated-db-password"
  analytics:
    publicAccessToken: "your-generated-public-token"
    privateAccessToken: "your-generated-private-token"
  dashboard:
    password: "your-generated-dashboard-password"
  realtime:
    secretKeyBase: "your-generated-realtime-secret"
  meta:
    cryptoKey: "your-generated-crypto-key"
```

## Step 3: Update application.yaml

Edit [application.yaml](application.yaml) and set your Git repository URL:

```yaml
source:
  repoURL: https://github.com/yourusername/supabase-kubernetes.git  # Change this!
```

## Step 4: Deploy

### Create the namespace first:
```powershell
kubectl apply -f deploy/namespace.yaml
```

### Deploy with ArgoCD:
```powershell
kubectl apply -f deploy/application.yaml
```

## Step 5: Monitor Deployment

```powershell
# Watch pods come up
kubectl get pods -n spalce-credaction-supabase -w

# Check ArgoCD application
argocd app get supabase

# Check all resources
kubectl get all -n spalce-credaction-supabase
```

## Step 6: Access Supabase

Once deployed, access at: **https://api.credaction.com**

Dashboard login:
- Username: `supabase-admin` (or what you set in values)
- Password: Your `secret.dashboard.password` value

## Troubleshooting

### Check pod logs:
```powershell
kubectl logs -n spalce-credaction-supabase -l app.kubernetes.io/name=supabase-auth
```

### Check PVCs:
```powershell
kubectl get pvc -n spalce-credaction-supabase
```

### Check ingress:
```powershell
kubectl get ingress -n spalce-credaction-supabase
kubectl describe ingress -n spalce-credaction-supabase
```

### Check certificate (if using cert-manager annotation):
```powershell
kubectl get certificate -n spalce-credaction-supabase
```

## Important Notes

⚠️ **Before deploying:**
1. Generate and update ALL secrets in values-k3s.yaml
2. Update Git repository URL in application.yaml
3. Ensure DNS points api.credaction.com to your cluster
4. If you want cert-manager to auto-generate certs, add this annotation to kong.ingress in values-k3s.yaml:
   ```yaml
   annotations:
     cert-manager.io/cluster-issuer: "your-issuer-name"
   ```

## Files You Need

**Essential:**
- ✅ [application.yaml](application.yaml) - ArgoCD app
- ✅ [values-k3s.yaml](values-k3s.yaml) - Configuration (UPDATE SECRETS!)
- ✅ [namespace.yaml](namespace.yaml) - Namespace

**Optional:**
- [secrets-example.yaml](secrets-example.yaml) - Example only, don't use as-is
- [cert-manager-issuer.yaml](cert-manager-issuer.yaml) - Skip if you already have issuer
- [appproject.yaml](appproject.yaml) - Optional RBAC, not needed for basic deployment
- [values-k3s-dev.yaml](values-k3s-dev.yaml) - Skip for now

**Not Needed:**
- ~~appproject.yaml~~ (optional)
- ~~cert-manager-issuer.yaml~~ (you already have it)
- ~~values-k3s-dev.yaml~~ (dev environment)
