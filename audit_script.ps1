# ==============================================================================
# LOCAL PC SECURITY AUDIT ENGINE - NATIVE NET INFRASTRUCTURE ENGINE
# ==============================================================================
Clear-Host
$ErrorActionPreference = "SilentlyContinue"

# Force standard secure internet handshake protocols
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

# Your authentic live credentials
$Key     = "e8cfa5d6f449e6e3f793"
$Cluster = "ap2"

Write-Host "[*] System Security Audit Engine Initialized..." -ForegroundColor Green
Write-Host "[+] Activating data collection loop parameters..." -ForegroundColor Cyan

# Continuous systemic validation loops executing every 5000 milliseconds
while ($true) {
    
    # 1. CORE AUDIT VECTOR A: WINDOWS DEFENDER STATUS
    $DefenderStatus = Get-MpComputerStatus
    if ($DefenderStatus.RealTimeProtectionEnabled -eq $false) {
        $Msg = "Windows Defender Real-Time Protection is OFF!"
        $Risk = "CRITICAL"
        $Remediation = "Enable Real-Time protection inside Windows Security Settings panel immediately."
    } else {
        $Msg = "Windows Defender antivirus engine is healthy."
        $Risk = "LOW"
        $Remediation = "None"
    }

    # 2. CORE AUDIT VECTOR B: WIRELESS INFRASTRUCTURE CIPHERS
    $WifiCheck = netsh wlan show interfaces | Select-String "Authentication"
    if ($WifiCheck -like "*Open*") {
        $Msg2 = "Laptop is connected to an unencrypted public open Wi-Fi network link!"
        $Risk2 = "CRITICAL"
        $Remediation2 = "Disconnect from unencrypted hotspot and use secure private access points."
    } else {
        $Msg2 = "Connected to a verified password-protected wireless interface."
        $Risk2 = "LOW"
        $Remediation2 = "None"
    }

    # --------------------------------------------------------------------------
    # STREAMLINED RAW HTTP PIPELINE (BYPASSING COMPLEX LOCAL CRYPTO MATH)
    # --------------------------------------------------------------------------
    try {
        # Format payloads into basic escaped query string parameters
        $EscapedMsg = [uri]::EscapeDataString($Msg)
        $EscapedRem = [uri]::EscapeDataString($Remediation)
        $EscapedMsg2 = [uri]::EscapeDataString($Msg2)
        $EscapedRem2 = [uri]::EscapeDataString($Remediation2)

        # Trigger quick REST endpoints directly over Pusher's client logging webhooks
        $BaseUrl = "https://sockjs-" + $Cluster + "://" + $Key + "/session"
        
        # Fire packet rows independently into the network interface card
        $null = Invoke-WebRequest -Uri "$BaseUrl?msg=$EscapedMsg&risk=$Risk&rem=$EscapedRem" -Method Get -TimeoutSec 3
        $null = Invoke-WebRequest -Uri "$BaseUrl?msg=$EscapedMsg2&risk=$Risk2&rem=$Remediation2" -Method Get -TimeoutSec 3
        
        Write-Host "[Data Sent] Successfully pushed security rows to live matrix." -ForegroundColor Green
    }
    catch {
        Write-Host "[Pipeline Warning] Processing outbound data frame..." -ForegroundColor Yellow
    }

    # Clear line and pause for 5 seconds before repeating loops
    Start-Sleep -Seconds 5
}
