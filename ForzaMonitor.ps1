# Forza Horizon 4 - Verbindungsmonitor / Connection monitor
# Strg+C beendet die Aufzeichnung. Mit M markierst du einen Abbruch.
# Ctrl+C stops recording. Press M to mark a disconnect.

param(
    [ValidateRange(1, 60)]
    [int]$IntervalSeconds = 2,
    [string]$OutputDirectory = (Join-Path ([Environment]::GetFolderPath('Desktop')) 'Forza-Monitor'),
    [ValidateSet('auto', 'de', 'en')]
    [string]$Language = 'auto'
)

$ErrorActionPreference = 'Continue'

if ($Language -eq 'auto') {
    try {
        $Language = if ((Get-UICulture).TwoLetterISOLanguageName -eq 'de') { 'de' } else { 'en' }
    } catch {
        $Language = 'en'
    }
}

$Texts = @{
    de = @{
        Running  = 'Forza Monitor läuft. Bei Abbruch M drücken; mit Strg+C beenden.'
        Interval = 'Intervall: {0} Sekunde(n) | Protokoll: {1}'
        Stopped  = 'Monitor beendet. Log: {0}'
        Marker   = 'ABBRUCH_MARKIERT'
        Unknown  = 'UNBEKANNT'
        Error    = 'FEHLER'
        Line     = '{0} | Internet: {1} | DNS: {2} | Teredo: {3} {4}'
        ColTime = 'Zeit'; ColEvent = 'Ereignis'; ColGateway = 'Gateway'; ColGatewayStatus = 'Gateway_Status'
        ColInternet = 'Internet'; ColDns = 'DNS_Xbox'; ColTeredoState = 'Teredo_Status'
        ColTeredoServer = 'Teredo_Server'; ColTeredoError = 'Teredo_Fehler'
        Delimiter = ';'
    }
    en = @{
        Running  = 'Forza monitor is running. Press M when you get disconnected; Ctrl+C to stop.'
        Interval = 'Interval: {0} second(s) | Log: {1}'
        Stopped  = 'Monitor stopped. Log: {0}'
        Marker   = 'DISCONNECT_MARKED'
        Unknown  = 'UNKNOWN'
        Error    = 'ERROR'
        Line     = '{0} | Internet: {1} | DNS: {2} | Teredo: {3} {4}'
        ColTime = 'Time'; ColEvent = 'Event'; ColGateway = 'Gateway'; ColGatewayStatus = 'Gateway_Status'
        ColInternet = 'Internet'; ColDns = 'DNS_Xbox'; ColTeredoState = 'Teredo_State'
        ColTeredoServer = 'Teredo_Server'; ColTeredoError = 'Teredo_Error'
        Delimiter = ','
    }
}
$L = $Texts[$Language]

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
    if ([string]::IsNullOrWhiteSpace($Target)) { return $L.Unknown }
    try {
        if (Test-Connection $Target -Count 1 -Quiet -ErrorAction Stop) { return 'OK' }
    } catch {}
    return $L.Error
}

function Test-Dns([string]$Name) {
    try {
        Resolve-DnsName $Name -ErrorAction Stop | Select-Object -First 1 | Out-Null
        return 'OK'
    } catch {
        return $L.Error
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
            if ($key.Key -eq 'M') { return $L.Marker }
        }
    } catch {}
    return ''
}

Write-Host $L.Running -ForegroundColor Green
Write-Host ($L.Interval -f $IntervalSeconds, $csv)

try {
    while ($true) {
        $gateway = Get-DefaultGateway
        $teredo = Get-TeredoState
        $internet = Test-Ping '1.1.1.1'
        $dnsXbox = Test-Dns 'xboxlive.com'
        $marker = Get-Marker
        $sample = [ordered]@{}
        $sample[$L.ColTime] = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        $sample[$L.ColEvent] = $marker
        $sample[$L.ColGateway] = $gateway
        $sample[$L.ColGatewayStatus] = Test-Ping $gateway
        $sample[$L.ColInternet] = $internet
        $sample[$L.ColDns] = $dnsXbox
        $sample[$L.ColTeredoState] = $teredo.Status
        $sample[$L.ColTeredoServer] = $teredo.Server
        $sample[$L.ColTeredoError] = $teredo.Error

        [pscustomobject]$sample | Export-Csv -Path $csv -Delimiter $L.Delimiter -NoTypeInformation -Encoding UTF8 -Append

        $color = if ($teredo.Status -match '^(qualified|qualifiziert)$') { 'Green' } elseif ($internet -eq 'OK') { 'Yellow' } else { 'Red' }
        $statusLine = $L.Line -f (Get-Date -Format 'HH:mm:ss'), $internet, $dnsXbox, $teredo.Status, $marker
        Write-Host $statusLine -ForegroundColor $color

        Start-Sleep -Seconds $IntervalSeconds
    }
} finally {
    Write-Host ($L.Stopped -f $csv) -ForegroundColor Yellow
}
