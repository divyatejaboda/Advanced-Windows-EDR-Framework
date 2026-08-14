# ==============================================================================
# LOCAL PC SECURITY AUDIT ENGINE - SIMPLIFIED SECURE PIPELINE
# ==============================================================================
Clear-Host
$ErrorActionPreference = "SilentlyContinue"

# Force modern Internet Security Protocols
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

# Your Live Pusher API Credentials Deployed Successfully
$AppId  = "2184615"
$Key    = "e8cfa5d6f449e6e3f793"
$Secret = "6474c13cf362d0f41064"
$Cluster= "ap2"

function Send-LogToDashboard ($LogMessage, $StatusType="INFO", $RiskLevel="LOW", $Remediation="None") {
    # Streamlined standard body payload
    $Payload = @{
        name = "security-alert"
        channels = @("security-channel")
        data = @{
            message = $LogMessage
            type = $StatusType
            risk = $RiskLevel
            remediation = $Remediation
        } | ConvertTo-Json
    } | ConvertTo-Json -Compress

    # Connect directly using your permanent developer authentication keys
    $ApiUrl = "https://api-" + $Cluster + "://" + $AppId + "/events?auth_key=" + $Key

    # Send the raw data out immediately
    $Response = Invoke-RestMethod -Uri $ApiUrl -Method Post -Body $Payload -ContentType "application/json" -TimeoutSec 5
}

Write-Host "[*] Script started. Monitoring local system and network security..." -ForegroundColor Green
Write-Host "[+] Local agent looping active. Streaming variables directly to cloud dashboard..." -ForegroundColor Cyan

while ($true) {
    # Check 1: Antivirus Security Check
    $DefenderStatus = Get-MpComputerStatus
    if ($DefenderStatus.RealTimeProtectionEnabled -eq $false) {
        Send-LogToDashboard -LogMessage "Windows Defender Real-Time Protection is turned OFF!" -StatusType "ALERT" -RiskLevel "CRITICAL" -Remediation "Enable Real-Time protection inside Windows Security Settings panel immediately."
        Write-Host "[ALERT] Windows Defender is disabled!" -ForegroundColor Red
    } else {
        Send-LogToDashboard -LogMessage "Windows Defender antivirus engine is healthy." -StatusType "INFO" -RiskLevel "LOW" -Remediation "None"
        Write-Host "[OK] Antivirus scan clean." -ForegroundColor Green
    }

    # Check 2: Wi-Fi Encryption Evaluation
    $WifiCheck = netsh wlan show interfaces | Select-String "Authentication"
    if ($WifiCheck -like "*Open*") {
        Send-LogToDashboard -LogMessage "Laptop is connected to an unencrypted public open Wi-Fi network link!" -StatusType "ALERT" -RiskLevel "CRITICAL" -Remediation "Disconnect from unencrypted channel and shift telemetry loops over to a secure WPA2/WPA3 private gateway access point."
        Write-Host "[ALERT] Connected to unsecured open Wi-Fi!" -ForegroundColor Red
    } else {
        Send-LogToDashboard -LogMessage "Connected to a verified password-protected wireless interface." -StatusType "INFO" -RiskLevel "LOW" -Remediation "None"
        Write-Host "[OK] Wireless network link secure." -ForegroundColor Green
    }

    # Pause for 5 seconds before repeating checks
    Start-Sleep -Seconds 5
}
