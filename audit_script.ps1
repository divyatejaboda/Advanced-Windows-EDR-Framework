# ==============================================================================
# ENTERPRISE COMPLIANT ENDPOINT DETECTION & INFRASTRUCTURE LOG ENGINE
# ==============================================================================
Clear-Host
$ErrorActionPreference = "Stop"

# Force System Telemetry Encryption Protocols
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

# Production Credentials Array
$AppId   = "2184615"
$Key     = "e8cfa5d6f449e6e3f793"
$Secret  = "6474c13cf362d0f41064"
$Cluster = "ap2"

function Send-TelemetryLog ($Message, $StatusType="INFO", $RiskLevel="LOW", $Remediation="None") {
    try {
        $EpochTime = [int][double]::Parse((Get-Date (Get-Date).ToUniversalTime() -UFormat %s))
        
        # FIXED: Built using a native Object Hash Table to completely eliminate quote errors
        $InnerPayload = @{
            message     = $Message
            type        = $StatusType
            risk        = $RiskLevel
            remediation = $Remediation
        } | ConvertTo-Json -Compress

        $PayloadObj = @{
            name     = "security-alert"
            channels = @("security-channel")
            data     = $InnerPayload
        }
        $PostData = $PayloadObj | ConvertTo-Json -Compress

        # Calculate exact body checksum signatures
        $Md5 = [System.Security.Cryptography.MD5]::Create()
        $BodyBytes = [System.Text.Encoding]::UTF8.GetBytes($PostData)
        $BodyHash = [System.BitConverter]::ToString($Md5.ComputeHash($BodyBytes)).Replace("-", "").ToLower()

        # Construct authentication query parameters
        $AuthQuery = "auth_key=$Key&auth_timestamp=$EpochTime&auth_version=1.0&body_md5=$BodyHash"
        $StringToSign = "POST`n/apps/$AppId/events`n$AuthQuery"

        # Apply HMAC-SHA256 signature sealing routine
        $Hmac = New-Object System.Security.Cryptography.HMACSHA256
        $Hmac.Key = [System.Text.Encoding]::UTF8.GetBytes($Secret)
        $SignatureBytes = $Hmac.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($StringToSign))
        $Signature = [System.BitConverter]::ToString($SignatureBytes).Replace("-", "").ToLower()

        # Build fully qualified endpoint path
        $TargetUri = "https://api-$://pusher.com"

        # Fire data frame securely down the network interface card
        $null = Invoke-RestMethod -Uri $TargetUri -Method Post -Body $PostData -ContentType "application/json" -TimeoutSec 5
        Write-Host "[STREAM ACTIVE] Telemetry data frame securely transmitted." -ForegroundColor Green
    }
    catch {
        Write-Host "[PIPELINE WARNING] Network anomaly identified: $_" -ForegroundColor Yellow
    }
}

Write-Host "[*] System Security Engine Initialized..." -ForegroundColor Green
Write-Host "[+] Activating device architecture monitoring loops..." -ForegroundColor Cyan

# Continuous evaluation loops executing every 5000 milliseconds
while ($true) {

    # Audit Vector 1: Anti-Malware Service Baseline Validation
    $Defender = Get-MpComputerStatus
    if ($Defender.RealTimeProtectionEnabled -eq $false) {
        Send-TelemetryLog -Message "Windows Defender Real-Time Protection is completely disabled!" -StatusType "ALERT" -RiskLevel "CRITICAL" -Remediation "Re-activate core anti-malware runtimes within the Windows Security console immediately."
    } else {
        Send-TelemetryLog -Message "Windows Defender engine verified healthy. Host baseline secure." -StatusType "INFO" -RiskLevel "LOW" -Remediation "None required."
    }

    # Audit Vector 2: Open-Air Local Area Connection suites
    $Wifi = netsh wlan show interfaces | Select-String "Authentication"
    if ($Wifi -like "*Open*") {
        Send-TelemetryLog -Message "Host interface bound to an insecure unencrypted open public wireless access link!" -StatusType "ALERT" -RiskLevel "CRITICAL" -Remediation "Drop open air wireless sockets immediately. Re-route data streams over secure cellular hotspots or private WPA3 channels."
    } else {
        Send-TelemetryLog -Message "Wireless data interface link bound to a protected cipher network profile." -StatusType "INFO" -RiskLevel "LOW" -Remediation "None required."
    }

    Start-Sleep -Seconds 5
}
