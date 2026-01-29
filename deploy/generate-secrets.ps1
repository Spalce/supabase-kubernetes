# Supabase Secret Generator for K3s Deployment (PowerShell)
# This script generates secure random secrets for Supabase deployment

Write-Host "===================================" -ForegroundColor Cyan
Write-Host "Supabase Secret Generator" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Generating secure secrets..." -ForegroundColor Yellow
Write-Host ""

# Function to generate base64 random string
function Get-RandomBase64 {
    param([int]$bytes)
    $randomBytes = New-Object byte[] $bytes
    [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($randomBytes)
    return [Convert]::ToBase64String($randomBytes)
}

# Function to generate hex random string
function Get-RandomHex {
    param([int]$bytes)
    $randomBytes = New-Object byte[] $bytes
    [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($randomBytes)
    return ($randomBytes | ForEach-Object { $_.ToString("x2") }) -join ''
}

Write-Host "1. JWT Secrets" -ForegroundColor Green
Write-Host "   Copy these to your values-k3s.yaml under 'secret.jwt'"
Write-Host ""
Write-Host "   JWT Secret (secret):"
Write-Host (Get-RandomBase64 64) -ForegroundColor White
Write-Host ""

Write-Host "2. Database Password" -ForegroundColor Green
Write-Host "   Copy this to 'secret.db.password'"
Write-Host ""
Write-Host "   Password:"
Write-Host (Get-RandomBase64 32) -ForegroundColor White
Write-Host ""

Write-Host "3. Analytics Tokens" -ForegroundColor Green
Write-Host "   Copy these to 'secret.analytics'"
Write-Host ""
Write-Host "   Public Access Token:"
Write-Host (Get-RandomBase64 32) -ForegroundColor White
Write-Host ""
Write-Host "   Private Access Token:"
Write-Host (Get-RandomBase64 32) -ForegroundColor White
Write-Host ""

Write-Host "4. Dashboard Password" -ForegroundColor Green
Write-Host "   Copy this to 'secret.dashboard.password'"
Write-Host ""
Write-Host "   Password:"
Write-Host (Get-RandomBase64 24) -ForegroundColor White
Write-Host ""

Write-Host "5. Realtime Secret Key Base" -ForegroundColor Green
Write-Host "   Copy this to 'secret.realtime.secretKeyBase'"
Write-Host ""
Write-Host "   Secret Key Base:"
Write-Host (Get-RandomBase64 64) -ForegroundColor White
Write-Host ""

Write-Host "6. Meta Encryption Key" -ForegroundColor Green
Write-Host "   Copy this to 'secret.meta.cryptoKey'"
Write-Host ""
Write-Host "   Crypto Key:"
Write-Host (Get-RandomHex 32) -ForegroundColor White
Write-Host ""

Write-Host "===================================" -ForegroundColor Cyan
Write-Host "⚠️  IMPORTANT SECURITY NOTES" -ForegroundColor Red
Write-Host "===================================" -ForegroundColor Cyan
Write-Host "1. Store these secrets securely (use a password manager)"
Write-Host "2. Never commit secrets to Git"
Write-Host "3. Use different secrets for each environment"
Write-Host "4. Rotate secrets periodically"
Write-Host "5. Consider using a secrets management solution:"
Write-Host "   - Sealed Secrets"
Write-Host "   - External Secrets Operator"
Write-Host "   - HashiCorp Vault"
Write-Host "===================================" -ForegroundColor Cyan
