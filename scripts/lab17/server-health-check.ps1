$os = Get-CimInstance Win32_OperatingSystem
$computer = Get-CimInstance Win32_ComputerSystem
$volume = Get-Volume -DriveLetter C
$network = Get-NetIPConfiguration |
    Where-Object { $_.IPv4Address }

Write-Host "=== SERVER IDENTITY ==="
Write-Host "Hostname: $env:COMPUTERNAME"
Write-Host "OS: $($os.Caption)"
Write-Host "Version: $($os.Version)"
Write-Host "Last Boot: $($os.LastBootUpTime)"

$uptime = (Get-Date) - $os.LastBootUpTime
Write-Host "Uptime: $([math]::Round($uptime.TotalHours,2)) hours"

Write-Host "`n=== COMPUTE ==="
Write-Host "CPU: $($computer.NumberOfLogicalProcessors) logical processors"
Write-Host "RAM: $([math]::Round($computer.TotalPhysicalMemory / 1GB,2)) GB"

Write-Host "`n=== STORAGE ==="
Write-Host "C: Health: $($volume.HealthStatus)"
Write-Host "C: Size: $([math]::Round($volume.Size / 1GB,2)) GB"
Write-Host "C: Free: $([math]::Round($volume.SizeRemaining / 1GB,2)) GB"
Write-Host "C: Free %: $([math]::Round(($volume.SizeRemaining / $volume.Size) * 100,2))"

Write-Host "`n=== NETWORK ==="
foreach ($n in $network) {
    Write-Host "Interface: $($n.InterfaceAlias)"
    Write-Host "IPv4: $($n.IPv4Address.IPAddress)"
    Write-Host "Gateway: $($n.IPv4DefaultGateway.NextHop)"
    Write-Host "DNS: $($n.DNSServer.ServerAddresses -join ', ')"
}

Write-Host "`n=== FIREWALL PROFILE ==="
$firewallProfile = Get-NetConnectionProfile |
    Select-Object InterfaceAlias, NetworkCategory
$firewallProfile |
    Format-Table -AutoSize |
    Out-String |
    Write-Host

Write-Host "=== CRITICAL SERVICES ==="
$criticalServices = Get-Service WinRM, W32Time, wuauserv |
    Select-Object Name, Status, StartType
$criticalServices |
    Format-Table -AutoSize |
    Out-String |
    Write-Host

Write-Host "=== RECENT SYSTEM WARNINGS / ERRORS ==="
$recentEvents = Get-WinEvent -FilterHashtable @{
    LogName   = 'System'
    StartTime = (Get-Date).AddHours(-24)
    Level     = 2,3
} -ErrorAction SilentlyContinue |
Select-Object -First 10 TimeCreated, Id, ProviderName, LevelDisplayName

if ($recentEvents) {
    $recentEvents |
        Format-Table -AutoSize |
        Out-String |
        Write-Host
}
else {
    Write-Host "No System warnings or errors found in the last 24 hours."
}
