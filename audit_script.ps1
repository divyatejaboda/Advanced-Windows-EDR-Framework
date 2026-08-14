# ==============================================================================
# LOCAL PC SECURITY AUDIT ENGINE - PRODUCTION VERSION
# ==============================================================================
Clear-Host
$ErrorActionPreference = "Stop" # Stop on errors to force troubleshooting outputs

# Force native secure internet communication protocols
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

# Verified Pusher Application Credentials
$AppId   = "2184615"
$Key     = "e8cfa5d6f449e6e3f793"
$Secret  = "6474c13cf362d0f41064"
$Cluster = "ap2"

function Send-LogToDashboard ($LogMessage, $StatusType="INFO", $RiskLevel="LOW", $Remediation="None") {
    try {
        $EpochTime = [int][double]::Parse((Get-Date (Get-Date).ToUniversalTime() -UFormat %s))
        
        # Format inner JSON parameters cleanly
        $DataString = '{\"message\":\"' + $LogMessage + '\",\"type\":\"' + $StatusType + '\",\"risk\":\"' + $RiskLevel + '\",\"remediation\":\"' + $Remediation + '\"}'
        $JsonPayload = '{"name":"security-alert","channel":"security-channel","data":"' + $DataString + '"}'
        
        # Generate the MD5 body signature required by Pusher Channels
        $Md5Engine = [System.Security.Cryptography.MD5]::Create()
        $PayloadBytes = [System.Text.Encoding]::UTF8.GetBytes($JsonPayload)
        $PayloadHash = [System.BitConverter]::ToString($Md5Engine.ComputeHash($PayloadBytes)).Replace("-", "").ToLower()
        
        # Build authentication signature
        $SignatureString = "POST`n/apps/$AppId/events`nauth_key=$Key&auth_timestamp=$EpochTime&auth_version=1.0&body_md5=$PayloadHash"
        $HmacEngine = New-Object System.Security.Cryptography.HMACSHA256
        $HmacEngine.Key = [System.Text.Encoding]::UTF8.GetBytes($Secret)
        $FinalSignature = [System.BitConverter]::ToString($HmacEngine.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($SignatureString))).Replace("-", "").ToLower()
        
        # Strict URL Parameter Construction
        $ApiUrl = "https://api-$://pusher.com"
        
        # Transmit the data payload over the network
        $Response = Invoke-RestMethod -Uri $ApiUrl -Method Post -Body $JsonPayload -ContentType "application/json" -TimeoutSec 5
        Write-Host "[Data Sent] Successfully streamed row: $LogMessage" -ForegroundColor Green
    }
    catch {
        Write-Host "[Network Error] Streaming failed: $_" -ForegroundColor Red
    }
}

Write-Host "[*] System Security Audit Engine Started..." -ForegroundColor Green
Write-Host "[+] Activating 5-second collection loop parameters..." -ForegroundColor Cyan

# Fire initial system startup baseline link confirmation
Send-LogToDashboard -LogMessage "Local tracking script connected successfully. Baseline established." -StatusType "INFO" -RiskLevel "LOW" -Remediation "None"

while ($true) {
    # ------------------ Security Audit Vector 1: Antivirus ------------------
    $DefenderStatus = Get-MpComputerStatus
    if ($DefenderStatus.RealTimeProtectionEnabled -eq $false) {
        Send-LogToDashboard -LogMessage "Windows Defender Real-Time Protection is turned OFF!" -StatusType "ALERT" -RiskLevel "CRITICAL" -Remediation "Enable Real-Time protection inside Windows Security Settings panel immediately."
    } else {
        Send-LogToDashboard -LogMessage "Windows Defender antivirus engine is healthy." -StatusType "INFO" -RiskLevel "LOW" -Remediation "None"
    }

    # ------------------ Security Audit Vector 2: Wi-Fi Encryption ------------------
    $WifiCheck = netsh wlan show interfaces | Select-String "Authentication"
    if ($WifiCheck -like "*Open*") {
        Send-LogToDashboard -LogMessage "Laptop is connected to an unencrypted public open Wi-Fi network link!" -StatusType "ALERT" -RiskLevel "CRITICAL" -Remediation "Disconnect from unencrypted channel and use a secure WPA2/WPA3 network."
    } else {
        Send-LogToDashboard -LogMessage "Connected to a verified password-protected wireless interface." -StatusType "INFO" -RiskLevel "LOW" -Remediation "None"
    }

    Start-Sleep -Seconds 5
}
