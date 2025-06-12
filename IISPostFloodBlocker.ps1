# Requires: Run as Administrator

# Path to IIS log directory (update as needed)
$logPath = "C:\inetpub\logs\LogFiles\W3SVC1"

# Time window and post threshold
$timeWindowSeconds = 10
$postThreshold = 10

# Get the latest log file
$logFile = Get-ChildItem -Path $logPath -Filter *.log | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if (-not $logFile) {
    Write-Host "No IIS log files found."
    exit
}

# Read log lines, skip comments
$logLines = Get-Content $logFile.FullName | Where-Object { $_ -notmatch "^#" }

# Parse log header for field positions
$headerLine = Get-Content $logFile.FullName | Where-Object { $_ -match "^#Fields:" } | Select-Object -Last 1
if (-not $headerLine) {
    Write-Host "No #Fields header found in log."
    exit
}
$fields = $headerLine -replace "^#Fields:\s+", "" -split "\s+"
$fieldMap = @{}
for ($i = 0; $i -lt $fields.Length; $i++) { $fieldMap[$fields[$i]] = $i }

# Ensure required fields exist
foreach ($f in @("date", "time", "c-ip", "cs-method")) {
    if (-not $fieldMap.ContainsKey($f)) {
        Write-Host "Log missing required field: $f"
        exit
    }
}

# Collect POST requests by IP and timestamp
$posts = @{}
foreach ($line in $logLines) {
    $cols = $line -split "\s+"
    if ($cols[$fieldMap["cs-method"]] -eq "POST") {
        $ip = $cols[$fieldMap["c-ip"]]
        $dt = "$($cols[$fieldMap["date"]]) $($cols[$fieldMap["time"]])"
        $timestamp = [datetime]::ParseExact($dt, "yyyy-MM-dd HH:mm:ss", $null)
        if (-not $posts.ContainsKey($ip)) { $posts[$ip] = @() }
        $posts[$ip] += $timestamp
    }
}

# Check for offending IPs
foreach ($ip in $posts.Keys) {
    $times = $posts[$ip] | Sort-Object
    for ($i = 0; $i -le $times.Count - $postThreshold; $i++) {
        $start = $times[$i]
        $end = $times[$i + $postThreshold - 1]
        if (($end - $start).TotalSeconds -le $timeWindowSeconds) {
            # Block IP in Windows Defender Firewall
            $ruleName = "Block IIS POST Flood $ip"
            if (-not (Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue)) {
                New-NetFirewallRule -DisplayName $ruleName -Direction Inbound -RemoteAddress $ip -Action Block
                Write-Host "Blocked IP: $ip"
            }
            break
        }
    }
}