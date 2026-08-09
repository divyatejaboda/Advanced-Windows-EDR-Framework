# Real-Time Windows System & Network Security Monitoring Utility

This project is a functional, real-time security tracking tool designed for Windows environments. It uses a decoupled client-server architecture: a local monitoring agent script runs on the machine to gather security logs, while a centralized web-based logging console hosted on GitHub Pages displays the live feed anywhere in the world.

## Core Security Checks Deployed
1. **Antivirus Engine Verification:** Leverages native `Get-MpComputerStatus` API hooks to continuously check if Windows Defender Real-Time Protection is running or has been disabled.
2. **Untrusted Process Isolation:** Scans active process directory footprints to identify unauthorized applications running inside volatile directories (such as `C:\Users\Public\`).
3. **Data Protection Auditing:** Queries local hardware drive parameters via BitLocker configurations to ensure the primary system volume (C:) is fully encrypted.
4. **Network Cipher Diagnostics:** Reads wireless interface properties (`netsh wlan`) to warn if the host machine connects to unsafe, unencrypted public Wi-Fi access points.
5. **DNS Cache Validation:** Automatically reviews local resolver memory metrics to look for hidden or poisoned domain redirection entry variations.
6. **Layer-2 Protection Routing:** Groups active link-layer neighbor addresses (`Get-NetNeighbor`) to catch duplicate MAC associations, protecting the endpoint against Man-in-the-Middle network spoofing.

## Data Transport & Web Architecture
The local tracking agent is engineered entirely in Windows PowerShell. Rather than storing logs locally, it packages system states into secure JSON payloads and pushes them outward via HTTPS (Port 443). 

Using the Pusher framework as a real-time WebSocket bridge, these data strings are immediately beamed directly onto the public front-end dashboard (`index.html`). This architecture completely bypasses the need for traditional hosting servers, allowing a static cloud site to update dynamically under a sub-150ms execution latency window.
