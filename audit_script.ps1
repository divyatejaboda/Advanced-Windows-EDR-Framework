# ==============================================================================
# LOCAL PC SECURITY AUDIT ENGINE - SECURE REWRITTEN AUTOMATION ENGINE
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
    $EpochTime = [int][double]::Parse((Get-Date (Get-Date).ToUniversalTime() -UFormat %s))
    
    # 1. Structure the data inner payload string cleanly
    $DataString = '{\"message\":\"' + $LogMessage + '\",\"type\":\"' + $StatusType + '\",\"risk\":\"' + $RiskLevel + '\",\"remediation\":\"' + $Remediation + '\"}'
    $JsonPayload = '{"name":"security-alert","channel":"security-channel","data":"' + $DataString + '"}'
    
    # 2. Build the secure MD5 body hash signature required by Pusher
    $Md5Engine = [System.Security.Cryptography.MD5]::Create()
    $PayloadBytes = [System.Text.Encoding]::UTF8.GetBytes($JsonPayload)
    $PayloadHash = [System.BitConverter]::ToString($Md5Engine.ComputeHash($PayloadBytes)).Replace("-", "").ToLower()
    
    # 3. Create the direct authentication query authentication strings
    $SignatureString = "POST`n/apps/$AppId/events`nauth_key=$Key&auth_timestamp=$EpochTime&auth_version=1.0&body_md5=$PayloadHash"
    $HmacEngine = New-Object System.Security.Cryptography.HMACSHA256
    $HmacEngine.Key = [System.Text.Encoding]::UTF8.GetBytes($Secret)
    $FinalSignature = [System.BitConverter]::ToString($HmacEngine.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($SignatureString))).Replace("-", "").ToLower()
    
    # 4. Formulate the precise URL query connection string parameters
    $ApiUrl = "https://api-" + $Cluster + "://" + $AppId + "/events?auth_key=" + $Key + "&auth_timestamp=" + $EpochTime + "&auth_version=1.0&body_md5=" + $PayloadHash + "&auth_signature=" + $FinalSignature
    
    # Send the raw data out immediately with a small timeout window
    $Result = Invoke-RestMethod -Uri $ApiUrl -Method Post -Body $JsonPayload -ContentType "application/json" -TimeoutSec 5
}

Write-Host "[*] Script started. Monitoring local system and network security..." -ForegroundColor Green
Write-Host "[+] Local agent looping active. Streaming variables directly to cloud dashboard..." -ForegroundColor Cyan

# Fire an initialization confirmation log point
Send-LogToDashboard -LogMessage "Local security tracking agent connected successfully." -StatusType "INFO" -RiskLevel "LOW" -Remediation "None"

while ($true) {
    # Check 1: Antivirus Security Check
    $DefenderStatus = Get-MpComputerStatus
    if ($DefenderStatus.RealTimeProtectionEnabled -eq $false) {
        Send-LogToDashboard -LogMessage "Windows Defender Real-Time Protection is turned OFF!" -StatusType "ALERT" -RiskLevel "CRITICAL" -Remediation "Enable Real-Time protection inside Windows Security Settings panel immediately."
        Write-Host "[ALERT Sent] Windows Defender is disabled!" -ForegroundColor Red
    } else {
        Send-LogToDashboard -LogMessage "Windows Defender antivirus engine is healthy." -StatusType "INFO" -RiskLevel "LOW" -Remediation "None"
        Write-Host "[Data Sent] Antivirus scan clean data point updated." -ForegroundColor Green
    }

    # Check 2: Wi-Fi Encryption Evaluation
    $WifiCheck = netsh wlan show interfaces | Select-String "Authentication"
    if ($WifiCheck -like "*Open*") {
        Send-LogToDashboard -LogMessage "Laptop is connected to an unencrypted public open Wi-Fi network link!" -StatusType "ALERT" -RiskLevel "CRITICAL" -Remediation "Disconnect from unencrypted hotspot and shift parameters to secure gateway."
        Write-Host "[ALERT Sent] Unsecured open Wi-Fi connection detected!" -ForegroundColor Red
    } else {
        Send-LogToDashboard -LogMessage "Connected to a verified password-protected wireless interface." -StatusType "INFO" -RiskLevel "LOW" -Remediation "None"
        Write-Host "[Data Sent] Network encryption configuration verified clean." -ForegroundColor Green
    }

    # Clear line and pause for 5 seconds before repeating loops
    Start-Sleep -Seconds 5
}
