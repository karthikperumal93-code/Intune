<#
.SYNOPSIS
    Cleans up system and user temporary files on Windows.
.DESCRIPTION
    Requires running as Administrator. Bypasses locked/in-use files safely.
#>

# 1. Enforce Administrator Rights
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Please run this script as an Administrator!"
    Exit
}

# 2. Define target cleanup locations
$TargetPaths = @(
    "$env:TEMP\*",                                      # Current User Temp
    "C:\Windows\Temp\*",                                # System Temp
    "C:\Windows\Prefetch\*"                             # Windows Prefetch
)

Write-Host "Starting temporary file cleanup..." -ForegroundColor Cyan

# 3. Loop through targets and remove files safely
foreach ($Path in $TargetPaths) {
    if (Test-Path (Split-Path $Path)) {
        Write-Host "Cleaning: $(Split-Path $Path)" -ForegroundColor Gray
        # -ErrorAction SilentlyContinue ensures the script won't crash on locked system files
        Remove-Item -Path $Path -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# 4. Trigger Native Windows Disk Cleanup for deep purging
Write-Host "Running native Windows Disk Cleanup..." -ForegroundColor Cyan
cleanmgr /sagerun:1 | Out-Null

Write-Host "Cleanup process complete!" -ForegroundColor Green
