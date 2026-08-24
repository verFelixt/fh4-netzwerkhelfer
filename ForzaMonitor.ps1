# Forza Horizon 4 - Verbindungsmonitor
# Strg+C beendet die Aufzeichnung. Mit M markierst du einen Abbruch.

param(
    [ValidateRange(1, 60)]
    [int]$IntervalSeconds = 2,
    [string]$OutputDirectory = (Join-Path ([Environment]::GetFolderPath('Desktop')) 'Forza-Monitor')
)

$ErrorActionPreference = 'Continue'
New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
$stamp = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'
$csv = Join-Path $OutputDirectory "ForzaMonitor_$stamp.csv"

function Get-DefaultGateway {
    try {
        $route = Get-NetRoute -DestinationPrefix '0.0.0.0/0' -ErrorAction Stop |
            Where-Object { $_.NextHop -and $_.NextHop -ne '0.0.0.0' -and $_.State -eq 'Alive' } |
            Sort-Object RouteMetric, InterfaceMetric |
            Select-Object -First 1
        if ($route) { return $route.NextHop }
    } catch {}
    return ''
}

function Test-Ping([string]$Target) {
    if ([string]::IsNullOrWhiteSpace($Target)) { return 'UNBEKANNT' }
    try {
        if (Test-Connection $Target -Count 1 -Quiet -ErrorAction Stop) { return 'OK' }
    } catch {}
    return 'FEHLER'
}

function Test-Dns([string]$Name) {
    try {
        Resolve-DnsName $Name -ErrorAction Stop | Select-Object -First 1 | Out-Null
        return 'OK'
    } catch {
        return 'FEHLER'
    }
}

function Get-TeredoValue {
    param([string]$Text, [string[]]$Labels)
    foreach ($label in $Labels) {
        $pattern = "(?im)^\s*$([regex]::Escape($label))\s*:\s*(.+)$"
        $match = [regex]::Match($Text, $pattern)
        if ($match.Success) { return $match.Groups[1].Value.Trim() }
    }
    return ''
}

function Get-TeredoState {
    $raw = netsh interface teredo show state 2>&1 | Out-String
    [pscustomobject]@{
        Status = Get-TeredoValue $raw @('Status', 'State', 'Zustand')
        Server = Get-TeredoValue $raw @('Servername', 'Server Name')
        Error  = Get-TeredoValue $raw @('Fehler', 'Error')
    }
}

function Get-Marker {
    try {
        if ([Console]::KeyAvailable) {
            $key = [Console]::ReadKey($true)
            if ($key.Key -eq 'M') { return 'ABBRUCH_MARKIERT' }
        }
    } catch {}
    return ''
}

Write-Host 'Forza Monitor läuft. Bei Abbruch M drücken; mit Strg+C beenden.' -ForegroundColor Green
Write-Host "Intervall: $IntervalSeconds Sekunde(n) | Protokoll: $csv"

try {
    while ($true) {
        $gateway = Get-DefaultGateway
        $teredo = Get-TeredoState
        $internet = Test-Ping '1.1.1.1'
        $sample = [pscustomobject][ordered]@{
            Zeit          = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
            Ereignis      = Get-Marker
            Gateway       = $gateway
            Gateway_Status = Test-Ping $gateway
            Internet      = $internet
            DNS_Xbox      = Test-Dns 'xboxlive.com'
            Teredo_Status = $teredo.Status
            Teredo_Server = $teredo.Server
            Teredo_Fehler = $teredo.Error
        }

        $sample | Export-Csv -Path $csv -Delimiter ';' -NoTypeInformation -Encoding UTF8 -Append

        $color = if ($sample.Teredo_Status -match '^(qualified|qualifiziert)$') { 'Green' } elseif ($internet -eq 'OK') { 'Yellow' } else { 'Red' }
        $statusLine = "{0} | Internet: {1} | DNS: {2} | Teredo: {3} {4}" -f (Get-Date -Format 'HH:mm:ss'), $sample.Internet, $sample.DNS_Xbox, $sample.Teredo_Status, $sample.Ereignis
        Write-Host $statusLine -ForegroundColor $color

        Start-Sleep -Seconds $IntervalSeconds
    }
} finally {
    Write-Host "Monitor beendet. Log: $csv" -ForegroundColor Yellow
}

