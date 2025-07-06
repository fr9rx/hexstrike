# Auto Installer for HexStrike
$destPath = "$env:USERPROFILE\hexstrike"
$profilePath = $PROFILE

# Step 1: نسخ الملفات لمكان دائم
if (-Not (Test-Path $destPath)) {
    git clone https://github.com/fr9rx/hexstrike.git $destPath
} else {
    Write-Host "HexStrike folder already exists at $destPath" -ForegroundColor Yellow
}

# Step 2: تأكد من إضافة المسار للـ PATH
$envPaths = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User)
if ($envPaths -notlike "*$destPath*") {
    [System.Environment]::SetEnvironmentVariable("Path", "$envPaths;$destPath", [System.EnvironmentVariableTarget]::User)
    Write-Host "✅ Added HexStrike to PATH" -ForegroundColor Green
} else {
    Write-Host "ℹ️ HexStrike is already in PATH" -ForegroundColor Cyan
}

# Step 3: إضافة alias للبروفايل تبع PowerShell
if (!(Test-Path -Path $profilePath)) {
    New-Item -ItemType File -Path $profilePath -Force
}

$profileContent = Get-Content $profilePath
$aliasLine = "Set-Alias hexstrike `"$destPath\hexstrike.ps1`""

if ($profileContent -notcontains $aliasLine) {
    Add-Content $profilePath "`n$aliasLine"
    Write-Host "✅ Alias 'hexstrike' added to PowerShell profile." -ForegroundColor Green
} else {
    Write-Host "ℹ️ Alias already exists." -ForegroundColor Cyan
}

Write-Host "`n🚀 Now restart PowerShell or run: `n. `$PROFILE`" -ForegroundColor Magenta
