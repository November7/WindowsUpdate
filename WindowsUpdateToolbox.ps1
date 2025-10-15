# ─────────────────────────────────────────────
# WINDOWS UPDATE TOOLBOX – INTERACTIVE SCRIPT
# Author: Nov7 
# ─────────────────────────────────────────────

function Show-Menu {
    Clear-Host
    Write-Host "==============================="
    Write-Host " WINDOWS UPDATE TOOLBOX"
    Write-Host "==============================="
    Write-Host "[1] Install PSWindowsUpdate module"
    Write-Host "[2] Check available updates"
    Write-Host "[3] Install specific KB update"
    Write-Host "[4] Show update history"
    Write-Host "[5] Clear update cache"
    Write-Host "[6] Check Windows Update service status"
    Write-Host "[7] Disable automatic updates (registry)"
    Write-Host "[0] Exit"
    Write-Host "==============================="
}

function Install-PSWindowsUpdate {
    Write-Host "Installing PSWindowsUpdate module..."
    Install-Module -Name PSWindowsUpdate -Force
    Import-Module PSWindowsUpdate
    Write-Host "Done.`n"
    Pause
}

function Check-AvailableUpdates {
    Import-Module PSWindowsUpdate
    Write-Host "Available updates:`n"
    Get-WindowsUpdate
    Pause
}

function Install-SpecificKB {
    Import-Module PSWindowsUpdate
    $kb = Read-Host "Enter KB update number (e.g. KB5029263)"
    Install-WindowsUpdate -KBArticleID $kb -AcceptAll -AutoReboot
    Pause
}

function Show-UpdateHistory {
    Import-Module PSWindowsUpdate
    Write-Host "Update history:`n"
    Get-WUHistory | Format-Table Date, KB, Result, UpdateType -AutoSize
    Pause
}

function Clear-UpdateCache {
    Write-Host "Stopping Windows Update service..."
    Stop-Service -Name wuauserv -Force
    Write-Host "Clearing cache folder..."
    Remove-Item -Path "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force
    Write-Host "Restarting service..."
    Start-Service -Name wuauserv
    Write-Host "Cache cleared.`n"
    Pause
}

function Check-ServiceStatus {
    $svc = Get-Service -Name wuauserv
    $wmi = Get-WmiObject -Class Win32_Service -Filter "Name='wuauserv'"
    Write-Host "Service status: $($svc.Status)"
    Write-Host "Startup type: $($wmi.StartMode)"
    Pause
}

function Disable-AutoUpdates {
    Write-Host "Disabling automatic updates via registry..."
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoUpdate" -Value 1
    Write-Host "Automatic updates have been disabled.`n"
    Pause
}

do {
    Show-Menu
    $choice = Read-Host "Choose an option"
    switch ($choice) {
        "1" { Install-PSWindowsUpdate }
        "2" { Check-AvailableUpdates }
        "3" { Install-SpecificKB }
        "4" { Show-UpdateHistory }
        "5" { Clear-UpdateCache }
        "6" { Check-ServiceStatus }
        "7" { Disable-AutoUpdates }
        "0" { Write-Host "Closing..."; break }
        default { Write-Host "Invalid selection. Please try again."; Pause }
    }
} while ($true)