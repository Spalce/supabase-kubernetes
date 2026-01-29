#!/bin/bash

# Supabase Secret Generator for K3s Deployment
# This script generates secure random secrets for Supabase deployment

echo "==================================="
echo "Supabase Secret Generator"
echo "==================================="
echo ""

echo "Generating secure secrets..."
echo ""

echo "1. JWT Secrets"
echo "   Copy these to your values-k3s.yaml under 'secret.jwt'"
echo ""
echo "   JWT Secret (secret):"
openssl rand -base64 64 | tr -d '\n'
echo ""
echo ""

echo "2. Database Password"
echo "   Copy this to 'secret.db.password'"
echo ""
echo "   Password:"
openssl rand -base64 32 | tr -d '\n'
echo ""
echo ""

echo "3. Analytics Tokens"
echo "   Copy these to 'secret.analytics'"
echo ""
echo "   Public Access Token:"
openssl rand -base64 32 | tr -d '\n'
echo ""
echo ""
echo "   Private Access Token:"
openssl rand -base64 32 | tr -d '\n'
echo ""
echo ""

echo "4. Dashboard Password"
echo "   Copy this to 'secret.dashboard.password'"
echo ""
echo "   Password:"
openssl rand -base64 24 | tr -d '\n'
echo ""
echo ""

echo "5. Realtime Secret Key Base"
echo "   Copy this to 'secret.realtime.secretKeyBase'"
echo ""
echo "   Secret Key Base:"
openssl rand -base64 64 | tr -d '\n'
echo ""
echo ""

echo "6. Meta Encryption Key"
echo "   Copy this to 'secret.meta.cryptoKey'"
echo ""
echo "   Crypto Key:"
openssl rand -hex 32
echo ""

echo "==================================="
echo "⚠️  IMPORTANT SECURITY NOTES"
echo "==================================="
echo "1. Store these secrets securely (use a password manager)"
echo "2. Never commit secrets to Git"
echo "3. Use different secrets for each environment"
echo "4. Rotate secrets periodically"
echo "5. Consider using a secrets management solution:"
echo "   - Sealed Secrets"
echo "   - External Secrets Operator"
echo "   - HashiCorp Vault"
echo "==================================="
