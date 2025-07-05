function Show_Menu {
    Clear-Host
    Write-Host "==============================" -ForegroundColor Red
    Write-Host "      HEX STRIKE TOOLKIT       " -ForegroundColor Red
    Write-Host "==============================" -ForegroundColor Red
    Write-Host "[1] Run Nmap"
    Write-Host "[2] Run Ping"
    Write-Host "[3] Monitor Mode On"
    Write-Host "[4] Monitor Mode Off "
    Write-Host "[5] Run Harvester"
    Write-Host "[6] Run Whois"
    Write-Host "[7] Run WireShark"
    Write-Host "[8] Run Nslookup"
    Write-Host "[9] Run Dig"
    write-host "[10] Run WhatWeb"
    Write-Host "[0] Exit"
    Write-Host "==============================" -ForegroundColor Red
}

function Nmap_host_scan {
    $ip = Read-Host "Enter IP"
    $arg = Read-Host "Enter nmap arguments"
    $argarray = $arg -split " "
    Start-Process -FilePath "nmap" -ArgumentList @($argarray + $ip) -NoNewWindow -RedirectStandardOutput "host_result.txt" -Wait 
    Write-Host "your results will be in a file named host_result.txt"
    Get-Content "host_result.txt"
    Pause
    Show-Menu
}

function Nmap_port_scan {
    $target = Read-Host "write an ip"
    $ports = Read-Host "write the ports you want"
    Start-Process -FilePath "nmap" -ArgumentList @("-p", $ports, $target) -NoNewWindow -RedirectStandardOutput "ports_result.txt" -Wait
    Write-Host "your result will be in ports_result.txt"
    Get-Content "ports_result.txt"
    Pause
    Show-Menu
}

function run_nmap {
    Clear-Host
    Write-Host "=============================" -ForegroundColor Red
    Write-Host "[1] Nmap Host Scan"
    Write-Host "[2] Nmap Ports Scan"
    Write-Host "[0] Return to Main Menu"
    Write-Host "=============================" -ForegroundColor Red
    $nmapchoice = Read-Host "select an option"
    switch ($nmapchoice) {
        "1" { Nmap_host_scan }
        "2" { Nmap_port_scan }
        "0" { Show-Menu }
        default { Write-Host "Invalid option."; Pause; Show-Menu }
    }
}

function Pingx {
    $target = Read-Host "Enter DNS or website"
    Start-Process -FilePath "ping" -ArgumentList ($target) -NoNewWindow -RedirectStandardOutput "ping_result.txt" -Wait
    Get-Content "ping_result.txt"
    Pause
    Show-Menu
}

function airmonx {
    $interface = Read-Host "Enter wlan0 or wlan1 or wlan2 depends on the nsme of wifi card"
    Start-Process -FilePath "airmon-ng" -ArgumentList @("start", $interface) -NoNewWindow
    Write-Host "Monitor mode enabled on $interface"
    Pause
    Show-Menu
}

function airmony {
    $interface = Read-Host "Enter the name of what you used in turning on monitor mode with mon in the end "
    Start-Process -FilePath "airmon-ng" -ArgumentList @("stop", $interface) -NoNewWindow
    Write-Host "Monitor mode disabled on $interface"
    Pause
    Show-Menu
}

function TheHarvesterx {
    $domain = Read-Host "Enter domain"
    $source = Read-Host "Enter source (google, bing, etc.)"
    Start-Process -FilePath "python" -ArgumentList @("theHarvester/theHarvester.py", "-d", $domain, "-b", $source) -NoNewWindow -RedirectStandardOutput "harvester_result.txt" -Wait
    Get-Content "harvester_result.txt"
    Pause
    Show-Menu
}

function whoisx {
    $domain = Read-Host "Enter domain"
    Start-Process -FilePath "whois" -ArgumentList $domain -NoNewWindow -RedirectStandardOutput "whois_result.txt" -Wait
    Get-Content "whois_result.txt"
    Pause
    Show-Menu
}

function wiresharkx {
    Start-Process -FilePath "wireshark"
    Pause
    Show-Menu
}
function nslookupx {
    $domain = Read-Host "Enter a domain"
    Start-Process -FilePath "nslookup" -ArgumentList $domain -NoNewWindow -RedirectStandardOutput "nslookup_result.txt" -Wait
    Write-Host "Result saved in nslookup_result.txt"
    Get-Content "nslookup_result.txt"
    pause
    show_menu
}

function digx {
    $domain = Read-Host "Enter a domain"
    Start-Process -FilePath "dig" -ArgumentList $domain -NoNewWindow -RedirectStandardOutput "dig_result.txt" -Wait
    Write-Host "Result saved in dig_result.txt"
    Get-Content "dig_result.txt"
    pause
    show_menu
}

function whatwebx {
    $url = Read-Host "Enter the target URL"
    Start-Process -FilePath "whatweb" -ArgumentList $url -NoNewWindow -RedirectStandardOutput "whatweb_result.txt" -Wait
    Write-Host "Result saved in whatweb_result.txt"
    Get-Content "whatweb_result.txt"
    Pause
    Show-Menu
}

while ($true) {
    Show_Menu
    $choice = Read-Host "Select an option"
    switch ($choice) {
        "1" { run_nmap }
        "2" { Pingx }
        "3" { airmonx }
        "4" { airmony }
        "5" { TheHarvesterx }
        "6" { whoisx }
        "7" { wiresharkx }
        "8" { Nslookupx }
        "9" { digx }
        "10" { whatwebx }
        "0" { exit }
        default { Write-Host "Invalid option. Try again." -ForegroundColor Red }
    }
}
