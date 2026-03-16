# validate_honeypot.ps1 - Post-deployment validation script for Windows

Write-Host "Starting Honeypot Deployment Validation..." -ForegroundColor Cyan

# 1. Check if honeypot files exist
$appdata = $env:APPDATA
$btc_path = Join-Path $appdata "Bitcoin\wallet.dat"
Write-Host -NoNewline "[ ] Checking honeypot files... "
if (Test-Path $btc_path) {
    Write-Host "DONE" -ForegroundColor Green
} else {
    Write-Host "FAILED (No artifacts found in $appdata)" -ForegroundColor Red
}

# 2. Check Wazuh Agent status
Write-Host -NoNewline "[ ] Checking Wazuh Agent... "
$wazuh_service = Get-Service -Name "Wazuh" -ErrorAction SilentlyContinue
if ($wazuh_service -and $wazuh_service.Status -eq "Running") {
    Write-Host "RUNNING" -ForegroundColor Green
} else {
    Write-Host "NOT RUNNING" -ForegroundColor Red
}

# 3. Check Sysmon status
Write-Host -NoNewline "[ ] Checking Sysmon... "
$sysmon_service = Get-Service -Name "Sysmon" -ErrorAction SilentlyContinue
if ($sysmon_service -and $sysmon_service.Status -eq "Running") {
    Write-Host "RUNNING" -ForegroundColor Green
} else {
    Write-Host "NOT RUNNING (Recommended for process visibility)" -ForegroundColor Yellow
}

# 4. Simulate access (OPTIONAL)
$choice = Read-Host "Do you want to trigger a test alert? (y/n)"
if ($choice -eq "y") {
    Write-Host "Accessing $btc_path..."
    Get-Content $btc_path -ErrorAction SilentlyContinue | Out-Null
    Write-Host "Test access performed. Check your Wazuh dashboard for Rule 100501." -ForegroundColor Green
}

Write-Host "Validation Complete."
