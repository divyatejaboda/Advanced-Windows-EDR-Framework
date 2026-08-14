# ==============================================================================
# LOCAL PC SECURITY AUDIT ENGINE - SECURE TLS PIPELINE MODEL
# ==============================================================================
Clear-Host
$ErrorActionPreference = "SilentlyContinue"

# FORCE NATIVE SECURE TLS ENCRYPTION HANDSHAKES
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

# Your Live Pusher API Credentials Deployed Successfully
$AppId  = "2184615"
$Key    = "e8cfa5d6f449e6e3f793"
$Secret = "6474c13cf362d0f41064"
$Cluster= "ap2"

function Send-LogToDashboard ($LogMessage, $StatusType="INFO", $RiskLevel="LOW", $Remediation="None") {
    $EpochTime = [int][double]::Parse((Get-Date (Get-Date).ToUniversalTime() -UFormat %s))
    
    # Pack parameters cleanly into a clear JSON payload
    $JsonPayload = '{"name":"security-alert","channel":"security-channel","data":"{\"message\":\"' + $LogMessage + '\",\"type\":\"' + $StatusType + '\",\"risk\":\"' + $RiskLevel + '\",\"remediation\":\"' + $Remediation + '\"}"}'
    
    $SystemMD5 = [System.Security.Cryptography.MD5]::Create()
    $PayloadBytes = [System.Text.Encoding]::UTF8.GetBytes($JsonPayload)
    $PayloadHash = [System.BitConverter]::ToString($SystemMD5.ComputeHash($PayloadBytes)).Replace("-", "").ToLower()
    
    $SignatureString = "POST`n/apps/$AppId/events`nauth_key=$Key&auth_timestamp=$EpochTime&auth_version=1.0&body_md5=$PayloadHash"
    $HmacEngine = New-Object System.Security.Cryptography.HMACSHA256
    $HmacEngine.Key = [System.Text.Encoding]::UTF8.GetBytes($Secret)
    $FinalSignature = [System.BitConverter]::ToString($HmacEngine.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($SignatureString))).Replace("-", "").ToLower()
    
    $ApiUrl = "https://api-" + $Cluster + "://" + $AppId + "/events?auth_key=" + $Key + "&auth_timestamp=" + $EpochTime + "&auth_version=1.0&body_md5=" + $PayloadHash + "&auth_signature=" + $FinalSignature
    
    Invoke-RestMethod -Uri $ApiUrl -Method Post -Body $JsonPayload -ContentType "application/json"
}

Write-Host "[*] Script started. Monitoring local system and network security..." -ForegroundColor Green
Send-LogToDashboard -LogMessage "Local tracking script connected successfully. Monitoring active." -StatusType "INFO" -RiskLevel "LOW" -Remediation "None"

while ($true) {
    # Check 1: Antivirus Security Check
    $DefenderStatus = Get-MpComputerStatus
    if ($DefenderStatus.RealTimeProtectionEnabled -eq $false) {
        Send-LogToDashboard -LogMessage "Windows Defender Real-Time Protection is turned OFF!" -StatusType "ALERT" -RiskLevel "CRITICAL" -Remediation "Enable Real-Time protection inside Windows Security Settings panel immediately."
    } else {
        Send-LogToDashboard -LogMessage "Windows Defender antivirus engine is healthy." -StatusType "INFO" -RiskLevel "LOW" -Remediation "None"
    }

    # Check 2: Public App Directory Audit
    $PublicProcess = Get-Process | Where-Object {$_.Path -like "*\Users\Public\*"}
    if ($PublicProcess) {
        Send-LogToDashboard -LogMessage "Suspicious process executing out of volatile public directory folder: $($PublicProcess.Name)" -StatusType "ALERT" -RiskLevel "HIGH" -Remediation "Isolate Process ID, terminate execution tree, and clean public directory files."
    }

    # Check 3: Wi-Fi Encryption Evaluation
    $WifiCheck = netsh wlan show interfaces | Select-String "Authentication"
    if ($WifiCheck -like "*Open*") {
        Send-LogToDashboard -LogMessage "Laptop is connected to an unencrypted public open Wi-Fi network link!" -StatusType "ALERT" -RiskLevel "CRITICAL" -Remediation "Disconnect from unencrypted channel and shift telemetry loops over to a secure WPA2/WPA3 private gateway access point."
    } else {
        Send-LogToDashboard -LogMessage "Connected to a verified password-protected wireless interface." -StatusType "INFO" -RiskLevel "LOW" -Remediation "None"
    }

    Start-Sleep -Seconds 5
}
