# Crypto Honeypot Post-Deployment Validation Script (Windows)
# This script simulates attacker activity to verify Wazuh detection.

Write-Host "Starting Crypto Honeypot Validation..." -ForegroundColor Cyan

# 1. Test Bitcoin Wallet Access (Read/Modify)
Write-Host -NoNewline "[*] Testing Bitcoin wallet access... "
$btcFile = Join-Path $env:APPDATA "Bitcoin\wallet.dat"
if (Test-Path $btcFile) {
    Get-Content $btcFile > $null
    Add-Content -Path $btcFile -Value "TAMPER"
    Write-Host "DONE" -ForegroundColor Green
} else {
    Write-Host "SKIPPED (File not found)" -ForegroundColor Red
}

# 2. Test Ethereum Keystore (Read)
Write-Host -NoNewline "[*] Testing Ethereum keystore access... "
$ethDir = Join-Path $env:APPDATA "Ethereum\keystore"
if (Test-Path $ethDir) {
    $ethFile = Get-ChildItem -Path $ethDir -Filter "UTC--*" | Select-Object -First 1
    if ($ethFile) {
        Get-Content $ethFile.FullName > $null
        Write-Host "DONE" -ForegroundColor Green
    } else {
        Write-Host "SKIPPED (No keystore file)" -ForegroundColor Red
    }
} else {
    Write-Host "SKIPPED (Dir not found)" -ForegroundColor Red
}

# 3. Test Browser Extension Data (Read/Delete)
Write-Host -NoNewline "[*] Testing Browser Extension data access... "
$chromeExt = Join-Path $env:LOCALAPPDATA "Google\Chrome\User Data\Default\Local Extension Settings\nkbihfbeogaeaoehlefnkodbefgpgknn\000003.log"
if (Test-Path $chromeExt) {
    Get-Content $chromeExt > $null
    Remove-Item $chromeExt
    Write-Host "DONE" -ForegroundColor Green
} else {
    Write-Host "SKIPPED (File not found)" -ForegroundColor Red
}

Write-Host "`nValidation actions completed." -ForegroundColor Green
Write-Host "Check your Wazuh Dashboard for alerts (Level 12) related to 'Crypto Honeypot'."
