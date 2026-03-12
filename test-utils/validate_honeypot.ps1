# validate_honeypot.ps1 - Verify Windows honeypot deployment and Wazuh integration

Write-Host "--- Crypto Wallet Honeypot: Windows Validation ---" -ForegroundColor Yellow

# 1. Check for honeypot artifacts
Write-Host "`nChecking for honeypot artifacts:" -ForegroundColor Gray
$AppData = [System.Environment]::GetFolderPath('ApplicationData')
$Artifacts = @(
    "$AppData\Bitcoin\wallet.dat",
    "$AppData\Ethereum\keystore",
    "$AppData\Electrum\wallets\default_wallet",
    "$AppData\Exodus\exodus.wallet"
)

foreach ($file in $Artifacts) {
    if (Test-Path $file) {
        Write-Host "  [OK] $file" -ForegroundColor Green
    } else {
        Write-Host "  [MISSING] $file" -ForegroundColor Yellow
    }
}

# 2. Check for browser extension decoys
Write-Host "`nChecking browser extension decoys:" -ForegroundColor Gray
$LocalAppData = [System.Environment]::GetFolderPath('LocalApplicationData')
$ExtIDs = @("nkbihfbeogaeaoehlefnkodbefgpgknn", "bfnaelmomeimhlpmgjnjophhpkkoljpa")
$ChromePath = "$LocalAppData\Google\Chrome\User Data\Default\Local Extension Settings"

foreach ($id in $ExtIDs) {
    $path = Join-Path $ChromePath $id
    if (Test-Path $path) {
        Write-Host "  [OK] Chrome Decoy: $id" -ForegroundColor Green
    } else {
        Write-Host "  [MISSING] Chrome Decoy: $id" -ForegroundColor Yellow
    }
}

# 3. Check for Sysmon
Write-Host "`nChecking Sysmon status:" -ForegroundColor Gray
$sysmon = Get-Service -Name "Sysmon*" -ErrorAction SilentlyContinue
if ($sysmon) {
    Write-Host "  [OK] Sysmon is installed and $($sysmon.Status)." -ForegroundColor Green
} else {
    Write-Host "  [WARNING] Sysmon not found. Process-level visibility may be limited." -ForegroundColor Yellow
}

# 4. Check Wazuh Agent
Write-Host "`nChecking Wazuh Agent status:" -ForegroundColor Gray
$wazuh = Get-Service -Name "Wazuh" -ErrorAction SilentlyContinue
if ($wazuh) {
    Write-Host "  [OK] Wazuh Agent is installed and $($wazuh.Status)." -ForegroundColor Green
} else {
    Write-Host "  [ERROR] Wazuh Agent service not found." -ForegroundColor Red
}

Write-Host "`nValidation Complete." -ForegroundColor Yellow
