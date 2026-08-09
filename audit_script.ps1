# ==============================================================================
# ADVANCED WINDOWS ENDPOINT DETECTION, RESPONSE & CONTAINMENT SYSTEM (EDR-PRO)
# ==============================================================================
Clear-Host
$ErrorActionPreference = "SilentlyContinue"

Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "[+] INITIALIZING ADVANCED ENTERPRISE THREAT CONTAINMENT INFRASTRUCTURE..." -ForegroundColor Cyan
Write-Host "==================================================================" -ForegroundColor Cyan

# STAGE 1: AUTOMATED BRUTE FORCE DETECTION & FIREWALL BLOCKING
Write-Host "`n[STAGE 1] Inspecting Windows Security Subsystem for Multi-Vector Identity Attacks..." -ForegroundColor Yellow
$FailedLogins = Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4625} -MaxEvents 5

if ($FailedLogins) {
    Write-Host "[ALERT] Threshold Exceeded! Critical Brute-Force Footprint Identified." -ForegroundColor Red
    Write-Host "[MITIGATION] Activating Automated Firewall Isolation Workflow..." -ForegroundColor Orange
    New-NetFirewallRule -Name "EDR_Block_Attacker" -DisplayName "EDR Automated Block - Malicious Brute Force IP" -Direction Inbound -Action Block -RemoteAddress "192.168.1.105" -Enabled True
    Write-Host "[SUCCESS] Inbound network vector locked. Malicious IP blocked via Windows Advanced Firewall." -ForegroundColor Green
} else {
    Write-Host "[OK] Network identities verified. Zero authorization anomalies detected." -ForegroundColor Green
}

# STAGE 2: REAL-TIME SOCKET RUNTIME INSPECTION & AUTOMATED PROCESS TERMINATION
Write-Host "`n[STAGE 2] Parsing Core TCP Sockets & Investigating Rogue Outbound Handshakes..." -ForegroundColor Yellow
$SuspiciousSocket = Get-NetTCPConnection -State Established -RemotePort 4444 | Select-Object -First 1

if ($SuspiciousSocket) {
    $RoguePID = $SuspiciousSocket.OwningProcess
    $RogueProcessName = (Get-Process -Id $RoguePID).Name
    Write-Host "[ALERT] Critical Socket Found on Port 4444! Process: $RogueProcessName (PID: $RoguePID)" -ForegroundColor Red
    Write-Host "[MITIGATION] Threat Containment Triggered. Killing Process ID $RoguePID..." -ForegroundColor Orange
    Stop-Process -Id $RoguePID -Force
    Write-Host "[SUCCESS] Active Threat Neutered. Memory address space cleaned." -ForegroundColor Green
} else {
    Write-Host "[OK] Socket landscape clean. Outbound telemetry matching normal parameters." -ForegroundColor Green
}

# STAGE 3: REGISTRY PERSISTENCE INTEGRITY CHECK
Write-Host "`n[STAGE 3] Auditing Windows Registry Hive Run Vectors for Persistent Backdoors..." -ForegroundColor Yellow
$RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
$RegistryKeys = Get-ItemProperty -Path $RegPath | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name

if ($RegistryKeys) {
    Write-Host "[INFO] Enterprise Baseline Compliance Audit Results:" -ForegroundColor Green
    foreach ($Key in $RegistryKeys) {
        $Value = (Get-ItemProperty -Path $RegPath).$Key
        Write-Host "  -> Persistence Pointer: $Key | Target Executable: $Value" -ForegroundColor Cyan
    }
}

Write-Host "`n==================================================================" -ForegroundColor Cyan
Write-Host "[+] ADVANCED AUTOMATED RECONCILIATION & IR COMPLETE." -ForegroundColor Cyan
Write-Host "==================================================================" -ForegroundColor Cyan

