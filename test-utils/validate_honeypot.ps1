# Validation script for Crypto Wallet Honeypot (Windows)
# This script simulates an attacker's actions to verify detection.

Write-Host "Starting Honeypot Validation..." -ForegroundColor Green

# 1. Check if artifacts exist
Write-Host "Checking for honeypot artifacts..."
$artifacts = @(
    "$env:APPDATA\Bitcoin\wallet.dat",
    "$env:APPDATA\Ethereum\keystore",
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Local Extension Settings\nkbihfbeogaeaoehlefnkodbefgpgknn"
)

$existCount = 0
foreach ($art in $artifacts) {
    if (Test-Path $art) {
        Write-Host "  [OK] Found $art"
        $existCount++
    } else {
        Write-Host "  [MISSING] $art" -ForegroundColor Yellow
    }
}

if ($existCount -eq 0) {
    Write-Host "Error: No artifacts found. Please run deploy.ps1 first." -ForegroundColor Red
}

# 2. Simulate Attack Actions
Write-Host "`nSimulating attacker actions (this should trigger Wazuh alerts)..." -ForegroundColor Green

# Simulate discovery
Write-Host "  Action: Listing Bitcoin directory..."
Get-ChildItem "$env:APPDATA\Bitcoin" -ErrorAction SilentlyContinue

# Simulate read
Write-Host "  Action: Reading Bitcoin wallet..."
if (Test-Path "$env:APPDATA\Bitcoin\wallet.dat") {
    Get-Content "$env:APPDATA\Bitcoin\wallet.dat" -ErrorAction SilentlyContinue | Out-Null
    Write-Host "  [OK] Read successful."
} else {
    Write-Host "  [SKIP] Bitcoin wallet not found."
}

# Simulate browser extension data access
Write-Host "  Action: Listing MetaMask data..."
$mmPath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Local Extension Settings\nkbihfbeogaeaoehlefnkodbefgpgknn"
if (Test-Path $mmPath) {
    Get-ChildItem $mmPath | Out-Null
    Write-Host "  [OK] List successful."
} else {
    Write-Host "  [SKIP] MetaMask data not found."
}

Write-Host "`nValidation actions completed." -ForegroundColor Green
Write-Host "Check your Wazuh dashboard for Rule IDs 100500, 100505, etc."
