# validate_honeypot.ps1 - Verify Crypto Wallet Honeypot Deployment

Write-Host "Starting Crypto Wallet Honeypot Validation..." -ForegroundColor Cyan

# 1. Check if honeypot-deployer is installed
$honeypotPath = Get-Command honeypot-deployer -ErrorAction SilentlyContinue
if ($null -eq $honeypotPath) {
    Write-Host "[FAIL] honeypot-deployer CLI not found. Install with 'pip install .'" -ForegroundColor Red
    exit 1
} else {
    Write-Host "[OK] honeypot-deployer CLI is installed." -ForegroundColor Green
}

# 2. Check for artifacts and manifest
if ((Test-Path ".\honeypot-artifacts") -and (Test-Path ".\honeypot-artifacts\manifest.json")) {
    Write-Host "[OK] Honeypot artifacts and manifest found." -ForegroundColor Green
} else {
    Write-Host "[FAIL] Honeypot artifacts not found. Generate them with 'honeypot-deployer generate --output .\honeypot-artifacts'" -ForegroundColor Red
    exit 1
}

# 3. Check Wazuh Agent configuration (Windows)
$ossecConf = "C:\Program Files (x86)\ossec-agent\ossec.conf"
if (Test-Path $ossecConf) {
    $confContent = Get-Content $ossecConf
    if ($confContent -match "bitcoin") {
        Write-Host "[OK] Wazuh FIM configuration appears to be present in ossec.conf" -ForegroundColor Green
    } else {
        Write-Host "[FAIL] Wazuh FIM configuration missing or incomplete in $ossecConf" -ForegroundColor Red
    }
} else {
    Write-Host "[INFO] Skipping $ossecConf check (not a standard Windows Wazuh Agent installation path)" -ForegroundColor Gray
}

# 4. Run honeypot-deployer health-check
Write-Host "Running honeypot-deployer health-check..." -ForegroundColor Cyan
honeypot-deployer health-check --manifest .\honeypot-artifacts\manifest.json

Write-Host "Validation complete." -ForegroundColor Cyan
