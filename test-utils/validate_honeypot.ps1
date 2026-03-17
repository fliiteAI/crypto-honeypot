# post-deployment validation script for Windows

Write-Host "--- Honeypot Deployment Validation (Windows) ---" -ForegroundColor Cyan

# 1. Check if artifacts exist
$bitcoinPath = Join-Path $env:APPDATA "Bitcoin\wallets\wallet.dat"
Write-Host -NoNewline "Checking for honeypot artifacts... "
if (Test-Path $bitcoinPath) {
    Write-Host "PRESENT" -ForegroundColor Green
} else {
    Write-Host "MISSING" -ForegroundColor Red
}

# 2. Check Wazuh Agent Status
Write-Host -NoNewline "Checking Wazuh Agent status... "
$wazuhService = Get-Service -Name "Wazuh" -ErrorAction SilentlyContinue
if ($wazuhService -and $wazuhService.Status -eq 'Running') {
    Write-Host "RUNNING" -ForegroundColor Green
} else {
    Write-Host "STOPPED/NOT INSTALLED" -ForegroundColor Red
}

# 3. Check Sysmon
Write-Host -NoNewline "Checking Sysmon status... "
$sysmonService = Get-Service -Name "Sysmon" -ErrorAction SilentlyContinue
if ($sysmonService -and $sysmonService.Status -eq 'Running') {
    Write-Host "RUNNING" -ForegroundColor Green
} else {
    Write-Host "STOPPED/NOT INSTALLED" -ForegroundColor Yellow
}

Write-Host "--------------------------------------------"
Write-Host "To trigger a test alert, run: type $bitcoinPath"
