# Automated Enterprise EDR & Threat Containment System (EDR-PRO)

An advanced, production-grade Endpoint Detection and Response (EDR) and Security Orchestration, Automation, and Response (SOAR) architectural framework engineered for enterprise Windows systems. This system transitions endpoint security from basic event collection into an autonomous mitigation and containment framework.

## Advanced Control Mechanisms & Core Subsystems
1. **Autonomous Identity Defense Block:** Monitors the Windows Event Layer for high-frequency **Event ID 4625** (Failed Logon) footprints. Upon detecting an intrusion profile, it programmatically injects blocking rules using the **Windows Advanced Firewall Subsystem (`New-NetFirewallRule`)**.
2. **Real-Time Memory & Socket Interception:** Continually audits network sockets via structural bindings (`Get-NetTCPConnection`). Upon isolating malicious unmapped tunnels (e.g., Reverse Shells on Port 4444), it resolves the anomalous connection directly to its internal system **Process ID (PID)** and executes forced thread execution terminations (`Stop-Process`).
3. **Persistence Vector Cryptanalysis:** Audits local machine initialization arrays (`HKCU:\Software\Microsoft\Windows\CurrentVersion\Run`) to find background configurations anomalies, blocking execution persistence vectors.

## Technical Stack Specifications
- **Automation Runtime Core:** Windows PowerShell Core (System Administration Engine)
- **Deployment Platform Architecture:** GitHub Pages Static Optimization Engine
- **Target Enterprise Landscapes:** Windows 10/11 Enterprise, Active Directory Datacenter Nodes
- 
