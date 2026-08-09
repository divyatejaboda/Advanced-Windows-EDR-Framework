# ==============================================================================
# LOCAL PC SECURITY AUDIT ENGINE
# ==============================================================================
Clear-Host
$ErrorActionPreference = "SilentlyContinue"

# Put your unique Pusher API credentials here
$AppId  = "2184615"
$Key    = "e8cfa5d6f449e6e3f793"
$Secret = "6474c13cf362d0f41064"
$Cluster= "ap2"

function Send-LogToDashboard ($LogMessage, $StatusType="INFO") {
    $EpochTime = [int][double]::Parse((Get-Date (Get-Date).ToUniversalTime() -UFormat %s))
    $JsonPayload = '{"name":"security-alert","channel":"security-channel","data":"{\"message\":\"' + $LogMessage + '\",\"type\":\"' + $StatusType + '\"}"}'
    
    $Md5Engine = [System.Security.Cryptography.MD5]::Create()
    $PayloadBytes = [System.Text.Encoding]::UTF8.GetBytes($JsonPayload)
    $PayloadHash = [System.BitConverter]::ToString($Md5Engine.ComputeHash($PayloadBytes)).Replace("-", "").ToLower()
    
    $SignatureString = "POST`n/apps/$AppId/events`nauth_key=$Key&auth_timestamp=$EpochTime&auth_version=1.0&body_md5=$PayloadHash"
    $HmacEngine = New-Object System.Security.Cryptography.HMACSHA256
    $HmacEngine.Key = [System.Text.Encoding]::UTF8.GetBytes($Secret)
    $FinalSignature = [System.BitConverter]::ToString($HmacEngine.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($SignatureString))).Replace("-", "").ToLower()
    
    $ApiUrl = "https://api-$://pusher.com"
    Invoke-RestMethod -Uri $ApiUrl -Method Post -Body $JsonPayload -ContentType "application/json"
}

Write-Host "[*] Script started. Monitoring local system and network security..." -ForegroundColor Green
Send-LogToDashboard -LogMessage "Local tracking script connected successfully. Monitoring active." -StatusType "INFO"

while ($true) {
    # Check 1: Make sure Windows Defender is turned on
    $DefenderStatus = Get-MpComputerStatus
    if ($DefenderStatus.RealTimeProtectionEnabled -eq $false) {
        Send-LogToDashboard -LogMessage "CRITICAL: Windows Defender Real-Time Protection is turned OFF!" -StatusType "ALERT"
    } else {
        Send-LogToDashboard -LogMessage "System Status: Windows Defender antivirus engine is healthy." -StatusType "INFO"
    }

    # Check 2: Look for suspicious apps running out of public folders
    $PublicProcess = Get-Process | Where-Object {$_.Path -like "*\Users\Public\*"}
    if ($PublicProcess) {
        Send-LogToDashboard -LogMessage "ALERT: Suspicious program running from a public folder: $($PublicProcess.Name)" -StatusType "ALERT"
    }

    # Check 3: Check if the main drive is encrypted with BitLocker
    $DriveCheck = Get-BitLockerVolume -MountPoint "C:"
    if ($DriveCheck.VolumeStatus -ne "FullyEncrypted") {
        Send-LogToDashboard -LogMessage "WARNING: C: drive is not encrypted. Data is vulnerable if laptop is lost." -StatusType "ALERT"
    }

    # Check 4: Check if your Wi-Fi connection is password protected
    $WifiCheck = netsh wlan show interfaces | Select-String "Authentication"
    if ($WifiCheck -like "*Open*") {
        Send-LogToDashboard -LogMessage "CRITICAL: Laptop is connected to an unencrypted public Wi-Fi network!" -StatusType "ALERT"
    } else {
        Send-LogToDashboard -LogMessage "Network Status: Connected to a secured Wi-Fi network link." -StatusType "INFO"
    }

    # Check 5: Look for fake or malicious entries inside the DNS cache
    $BadDns = Get-DnsClientCache | Where-Object {$_.EntryName -like "*malicious*" -or $_.EntryName -like "*phishing*"}
    if ($BadDns) {
        Send-LogToDashboard -LogMessage "ALERT: Malicious or poisoned domain match found in DNS local cache!" -StatusType "ALERT"
    }

    # Check 6: Check for ARP spoofing (Man-in-the-Middle tracking)
    $DuplicateMacs = Get-NetNeighbor | Group-Object LinkLayerAddress | Where-Object {$_.Count -gt 1 -and $_.Name -ne "00-00-00-00-00-00" -and $_.Name -ne "ff-ff-ff-ff-ff-ff"}
    if ($DuplicateMacs) {
        Send-LogToDashboard -LogMessage "ALERT: Possible Man-in-the-Middle attack. Duplicate MAC addresses found in network routing table." -StatusType "ALERT"
    }

    Start-Sleep -Seconds 5
}
