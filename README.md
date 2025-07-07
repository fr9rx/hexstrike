
HexStrike is a terminal-based (TUI) cybersecurity toolkit built with PowerShell for Windows and Kali Linux users. It combines essential reconnaissance, scanning, and monitoring tools in one interactive interface for white-hat ethical hacking purposes.

⚠️ This tool is for educational and authorized security testing purposes only.

🧰 Included Tools
Nmap – Host and Port Scanning

Ping – Reachability and Latency Check

Airmon-ng – Enable/Disable Monitor Mode (Kali)

theHarvester – OSINT Collection

Whois – Domain Information Lookup

Wireshark – GUI-based Packet Sniffer

nslookup – DNS Query Tool

dig – DNS Investigation Tool

whatweb – Web Tech Fingerprinting

⚙️ Requirements
Make sure these tools are installed and added to PATH:

🔵 Windows:
PowerShell 7+

Nmap

Wireshark

Python 3

Install theHarvester:

powershell
Copy
Edit
git clone https://github.com/laramies/theHarvester
cd theHarvester
python -m pip install -r requirements.txt
🐧 Kali Linux:
Already comes with most tools. Just make sure they are accessible in $PATH.

Check installation with:

bash
Copy
Edit
which nmap
which airmon-ng
which theHarvester
which dig
which nslookup
🚀 Run HexStrike
On Windows PowerShell:
powershell
Copy
Edit
cd path\to\HexStrike
.\hexstrike.ps1
If execution is blocked:

powershell
Copy
Edit
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
On Kali Linux PowerShell:
bash
Copy
Edit
pwsh
cd ~/HexStrike
./hexstrike.ps1
💡 Tips
Run as administrator/root for better results (especially for monitor mode).

Save results before exiting if needed. Most scans export .txt reports.
to added to path :
1.Log in to PowerShell as Admin

Run:

com.powershell
Copy
Edit
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
Then:

com.powershell
Copy
Edit
IRM https://raw.githubusercontent.com/fr9rx/hexstrike/main/install.ps1 | AIX
That's it! You can type:

com.powershell
Copy
Edit
com.hexstrike
and run it from anywhere.
🛡️ License & Legal
This project is for legal and ethical hacking. You are responsible for how you use this tool. Don't be a skiddie.

