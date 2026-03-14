# Post-deployment validation script for Crypto Wallet Honeypot (Windows)
# Verifies that artifacts are present and Sysmon/Wazuh are monitoring them.

Write-Host "Starting Honeypot Deployment Validation..." -ForegroundColor Yellow

# 1. Check if Wazuh Agent service is running
$wazuhService = Get-Service -Name "Wazuh" -ErrorAction SilentlyContinue
if ($wazuhService -and $wazuhService.Status -eq "Running") {
    Write-Host "[OK] Wazuh Agent is running" -ForegroundColor Green
} else {
    Write-Host "[FAIL] Wazuh Agent is NOT running" -ForegroundColor Red
}

# 2. Check if Sysmon is running
$sysmonService = Get-Service -Name "Sysmon64" -ErrorAction SilentlyContinue
if ($sysmonService -and $sysmonService.Status -eq "Running") {
    Write-Host "[OK] Sysmon is running" -ForegroundColor Green
} else {
    Write-Host "[WARN] Sysmon is NOT running. Process-level visibility may be limited." -ForegroundColor Yellow
}

# 3. Verify core honeypot files
$appData = $env:APPDATA
$localAppData = $env:LOCALAPPDATA
$userProfile = $env:USERPROFILE

$paths = @(
    "$appData\Bitcoin\wallet.dat",
    "$appData\Ethereum\keystore",
    "$userProfile\.config\solana\id.json",
    "$localAppData\Google\Chrome\User Data\Default\Local Extension Settings\nkbihfbeogaeaoehlefnkodbefgpgknn"
)

foreach ($path in $paths) {
    if (Test-Path $path) {
        Write-Host "[OK] Artifact exists: $path" -ForegroundColor Green
    } else {
        Write-Host "[INFO] Artifact missing (might not be deployed): $path" -ForegroundColor Yellow
    }
}

# 4. Check Wazuh FIM config (basic check)
$ossecConf = "C:\Program Files (x86)\ossec-agent\ossec.conf"
if (Test-Path $ossecConf) {
    $content = Get-Content $ossecConf
    if ($content -match "check_all") {
        Write-Host "[OK] Wazuh FIM appears to be configured" -ForegroundColor Green
    } else {
        Write-Host "[WARN] Could not confirm FIM config in ossec.conf" -ForegroundColor Yellow
    }
}

Write-Host "`nValidation Complete." -ForegroundColor Yellow
Write-Host "To trigger a test alert, run: type `"$appData\Bitcoin\wallet.dat`""
