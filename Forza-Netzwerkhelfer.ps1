# Forza Horizon 4 Netzwerkhelfer / Network Helper 1.2.0
# Interaktiver, lokaler Prüfer. Alle Änderungen erfordern eine Bestätigung.
# Interactive local checker. Every change requires confirmation.

param(
    [ValidateSet('auto', 'de', 'en')]
    [string]$Language = 'auto'
)

$ErrorActionPreference = 'Stop'
$ToolVersion = '1.2.0'
$TargetTeredoServer = 'win10.ipv6.microsoft.com'
$DnsV4 = @('1.1.1.1', '1.0.0.1')
$DnsV6 = @('2606:4700:4700::1111', '2606:4700:4700::1001')
$PackageRoot = Split-Path -Parent $PSCommandPath

# ---------------------------------------------------------------------------
# Sprache / Language
# ---------------------------------------------------------------------------
if ($Language -eq 'auto') {
    try {
        $Language = if ((Get-UICulture).TwoLetterISOLanguageName -eq 'de') { 'de' } else { 'en' }
    } catch {
        $Language = 'en'
    }
}
$script:Lang = $Language

$script:Texts = @{
    de = @{
        'title'            = 'FORZA HORIZON 4 - NETZWERKHELFER v{0}'
        'intro'            = 'Die Prüfung ist lokal. Änderungen erfolgen nur nach deiner Bestätigung.'
        'diagOnly'         = 'Nur-Diagnose-Modus: Reparaturaktionen benötigen einen Neustart als Administrator.'
        'legend'           = '[OK] = passt   [X] = fehlt/abweichend   [!] = Hinweis'
        'needAdmin'        = 'Diese Reparatur benötigt Administratorrechte.'
        'needAdminHow'     = 'Wähle A für einen Neustart als Administrator oder starte die Batch-Datei per Rechtsklick als Administrator.'
        'pressEnter'       = 'Weiter mit Eingabetaste'
        'adminFailed'      = 'Administrator-Neustart fehlgeschlagen: {0}'
        'adminFailedHow'   = 'Bitte die Batch-Datei per Rechtsklick und Als Administrator ausführen starten.'
        'noRoute'          = 'Keine aktive IPv4-Standardroute gefunden.'
        'notInstalled'     = 'nicht installiert'
        'notDetected'      = 'nicht erkannt'
        'active'           = 'aktiv'
        'disabled'         = 'deaktiviert'
        'none'             = 'keine'
        'chk.adapter'      = 'Aktiver Gaming-Adapter'
        'chk.ipv6'         = 'IPv6 am Gaming-Adapter'
        'chk.dns'          = 'Cloudflare DNS (IPv4/IPv6)'
        'chk.teredoType'   = 'Teredo-Modus'
        'chk.teredoState'  = 'Teredo-Status'
        'chk.teredoServer' = 'Teredo-Server'
        'chk.teredoPort'   = 'Teredo-Clientport'
        'chk.iphlp'        = 'IP-Hilfsdienst'
        'chk.gaming'       = 'Gaming Services'
        'chk.xbox'         = 'Xbox Netzwerkdienst'
        'chk.firewall'     = 'Windows-Firewall: Teredo'
        'chk.filters'      = 'Aktive VPN-/Virtualisierungsfilter'
        'chk.router'       = 'FRITZ!Box (manuell prüfen)'
        'det.dnsOther'     = '{0} (optional, Aktion 2)'
        'det.typeOk'       = '{0}'
        'det.typeOkGpo'    = '{0} - per Gruppenrichtlinie gesetzt, passt'
        'det.typeBad'      = 'aktuell: {0} - Aktion 3 setzt enterpriseclient'
        'det.typeBadGpo'   = 'aktuell: {0}, per Gruppenrichtlinie erzwungen - Aktion 3 wirkt nicht, in gpedit.msc ändern (siehe README)'
        'det.stateHint'    = '{0} (im Leerlauf normal; während FH4 online läuft, sollte qualified stehen)'
        'det.serverBad'    = 'aktuell: {0} - Aktion 3 setzt {1}'
        'det.portBad'      = 'aktuell: {0} - Aktion 3 stellt auf automatisch'
        'det.firewall'     = '{0} erlaubende Regel(n)'
        'det.router'       = 'Teredo-Filter aus; selbstständige Portfreigaben für den PC an'
        'confirmIpv6'      = "IPv6 auf '{0}' aktivieren?"
        'doneIpv6'         = 'IPv6 wurde aktiviert.'
        'confirmDns'       = "DNS auf Cloudflare am Adapter '{0}' setzen?"
        'doneDns'          = 'DNS wurde auf Cloudflare gesetzt.'
        'confirmTeredo'    = "Teredo auf enterpriseclient mit '{0}' und automatischem Port setzen?"
        'doneTeredo'       = 'Teredo-Konfiguration gesetzt.'
        'gpoWarn'          = 'Achtung: Teredo wird per Gruppenrichtlinie gesteuert. Werte aus der Richtlinie haben Vorrang vor dieser Änderung.'
        'confirmServices'  = 'IP-Hilfsdienst, Gaming Services und Xbox Netzwerkdienst starten?'
        'doneServices'     = 'Dienste wurden gestartet, soweit Windows dies erlaubt.'
        'yesNo'            = '(J/N)'
        'rep.title'        = 'FORZA HORIZON 4 - DIAGNOSEBERICHT'
        'rep.version'      = 'Netzwerkhelfer: v{0}'
        'rep.time'         = 'Zeit: {0}'
        'rep.adapter'      = 'Adapter: {0}'
        'rep.col.check'    = 'Pruefung'
        'rep.col.status'   = 'Status'
        'rep.col.details'  = 'Details'
        'rep.privacy'      = 'Hinweis: Der Bericht enthält keine absichtlich ermittelte öffentliche IP-Adresse und wird nicht hochgeladen.'
        'rep.saved'        = 'Diagnosebericht gespeichert: {0}'
        'rep.file'         = 'Forza-Diagnose_{0}.txt'
        'monNotFound'      = 'Monitor nicht gefunden: {0}'
        'checkFailed'      = 'Prüfung fehlgeschlagen: {0}'
        'checkFailedHow'   = 'Bitte Netzwerkverbindung und Windows-Netzwerkdienste prüfen.'
        'actionFailed'     = 'Aktion fehlgeschlagen: {0}'
        'menu'             = 'Aktionen:'
        'menu1'            = '  1  IPv6 aktivieren'
        'menu2'            = '  2  DNS auf Cloudflare setzen'
        'menu3'            = '  3  Empfohlene Teredo-Konfiguration setzen'
        'menu4'            = '  4  Xbox-/Netzwerkdienste starten'
        'menu5'            = '  5  Diagnosebericht speichern'
        'menu6'            = '  6  Forza Monitor starten'
        'menuA'            = '  A  Als Administrator neu starten'
        'menuL'            = '  L  Language: English'
        'menuR'            = '  R  Prüfung aktualisieren'
        'menuQ'            = '  Q  Beenden'
        'choice'           = 'Auswahl'
    }
    en = @{
        'title'            = 'FORZA HORIZON 4 - NETWORK HELPER v{0}'
        'intro'            = 'All checks run locally. Nothing is changed without your confirmation.'
        'diagOnly'         = 'Diagnose-only mode: repair actions require a restart as administrator.'
        'legend'           = '[OK] = fine   [X] = missing/different   [!] = note'
        'needAdmin'        = 'This repair requires administrator rights.'
        'needAdminHow'     = 'Choose A to restart as administrator, or right-click the batch file and run it as administrator.'
        'pressEnter'       = 'Press Enter to continue'
        'adminFailed'      = 'Restart as administrator failed: {0}'
        'adminFailedHow'   = 'Please right-click the batch file and choose "Run as administrator".'
        'noRoute'          = 'No active IPv4 default route found.'
        'notInstalled'     = 'not installed'
        'notDetected'      = 'not detected'
        'active'           = 'enabled'
        'disabled'         = 'disabled'
        'none'             = 'none'
        'chk.adapter'      = 'Active gaming adapter'
        'chk.ipv6'         = 'IPv6 on gaming adapter'
        'chk.dns'          = 'Cloudflare DNS (IPv4/IPv6)'
        'chk.teredoType'   = 'Teredo type'
        'chk.teredoState'  = 'Teredo state'
        'chk.teredoServer' = 'Teredo server'
        'chk.teredoPort'   = 'Teredo client port'
        'chk.iphlp'        = 'IP Helper service'
        'chk.gaming'       = 'Gaming Services'
        'chk.xbox'         = 'Xbox Live Networking Service'
        'chk.firewall'     = 'Windows Firewall: Teredo'
        'chk.filters'      = 'Active VPN/virtualization filters'
        'chk.router'       = 'Router (check manually)'
        'det.dnsOther'     = '{0} (optional, action 2)'
        'det.typeOk'       = '{0}'
        'det.typeOkGpo'    = '{0} - set by Group Policy, fine'
        'det.typeBad'      = 'current: {0} - action 3 sets enterpriseclient'
        'det.typeBadGpo'   = 'current: {0}, forced by Group Policy - action 3 cannot override it, change it in gpedit.msc (see README)'
        'det.stateHint'    = '{0} (normal when idle; should be qualified while FH4 is online)'
        'det.serverBad'    = 'current: {0} - action 3 sets {1}'
        'det.portBad'      = 'current: {0} - action 3 sets it to automatic'
        'det.firewall'     = '{0} allow rule(s)'
        'det.router'       = 'FRITZ!Box: Teredo filter off; allow automatic port sharing for the PC (UPnP)'
        'confirmIpv6'      = "Enable IPv6 on '{0}'?"
        'doneIpv6'         = 'IPv6 has been enabled.'
        'confirmDns'       = "Set Cloudflare DNS on adapter '{0}'?"
        'doneDns'          = 'DNS has been set to Cloudflare.'
        'confirmTeredo'    = "Set Teredo to enterpriseclient with '{0}' and automatic client port?"
        'doneTeredo'       = 'Teredo configuration applied.'
        'gpoWarn'          = 'Note: Teredo is controlled by Group Policy. Policy values take precedence over this change.'
        'confirmServices'  = 'Start IP Helper, Gaming Services and Xbox Live Networking Service?'
        'doneServices'     = 'Services started as far as Windows allows.'
        'yesNo'            = '(Y/N)'
        'rep.title'        = 'FORZA HORIZON 4 - DIAGNOSTIC REPORT'
        'rep.version'      = 'Network helper: v{0}'
        'rep.time'         = 'Time: {0}'
        'rep.adapter'      = 'Adapter: {0}'
        'rep.col.check'    = 'Check'
        'rep.col.status'   = 'Status'
        'rep.col.details'  = 'Details'
        'rep.privacy'      = 'Note: This report does not intentionally collect your public IP address and is not uploaded anywhere.'
        'rep.saved'        = 'Diagnostic report saved: {0}'
        'rep.file'         = 'Forza-Diagnostics_{0}.txt'
        'monNotFound'      = 'Monitor not found: {0}'
        'checkFailed'      = 'Check failed: {0}'
        'checkFailedHow'   = 'Please check your network connection and Windows network services.'
        'actionFailed'     = 'Action failed: {0}'
        'menu'             = 'Actions:'
        'menu1'            = '  1  Enable IPv6'
        'menu2'            = '  2  Set Cloudflare DNS'
        'menu3'            = '  3  Set recommended Teredo configuration'
        'menu4'            = '  4  Start Xbox/network services'
        'menu5'            = '  5  Save diagnostic report'
        'menu6'            = '  6  Start Forza monitor'
        'menuA'            = '  A  Restart as administrator'
        'menuL'            = '  L  Sprache: Deutsch'
        'menuR'            = '  R  Refresh checks'
        'menuQ'            = '  Q  Quit'
        'choice'           = 'Choice'
    }
}

function T {
    param([string]$Key)
    $text = $script:Texts[$script:Lang][$Key]
    if ($null -eq $text) { $text = $Key }
    if ($args.Count -gt 0) { return ($text -f $args) }
    return $text
}

# ---------------------------------------------------------------------------
# Hilfsfunktionen / Helpers
# ---------------------------------------------------------------------------
function Test-IsAdmin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Require-Admin {
    if ($script:IsAdmin) { return $true }
    Write-Host (T 'needAdmin') -ForegroundColor Yellow
    Write-Host (T 'needAdminHow') -ForegroundColor Yellow
    Read-Host (T 'pressEnter') | Out-Null
    return $false
}

function Restart-AsAdmin {
    try {
        $arguments = "-NoProfile -NoExit -ExecutionPolicy Bypass -File `"$PSCommandPath`" -Language $script:Lang"
        Start-Process powershell.exe -Verb RunAs -ArgumentList $arguments -ErrorAction Stop
        exit
    } catch {
        Write-Host (T 'adminFailed' $_.Exception.Message) -ForegroundColor Red
        Write-Host (T 'adminFailedHow') -ForegroundColor Yellow
        Read-Host (T 'pressEnter') | Out-Null
    }
}

function Get-ActiveAdapter {
    $route = Get-NetRoute -DestinationPrefix '0.0.0.0/0' -ErrorAction Stop |
        Where-Object { $_.NextHop -ne '0.0.0.0' -and $_.State -eq 'Alive' } |
        Sort-Object RouteMetric, InterfaceMetric | Select-Object -First 1
    if (-not $route) { throw (T 'noRoute') }
    Get-NetAdapter -InterfaceIndex $route.IfIndex -ErrorAction Stop
}

function Get-TeredoText { netsh interface teredo show state 2>&1 | Out-String }

function Get-TeredoValue {
    param([string]$Text, [string[]]$Labels)
    foreach ($label in $Labels) {
        $pattern = "(?im)^\s*$([regex]::Escape($label))\s*:\s*(.+)$"
        $match = [regex]::Match($Text, $pattern)
        if ($match.Success) { return $match.Groups[1].Value.Trim() }
    }
    return ''
}

# netsh hängt bei Werten aus einer Gruppenrichtlinie z. B. "(Group Policy)" an.
# netsh appends e.g. "(Group Policy)" to values that come from a Group Policy.
function Test-IsPolicyValue([string]$Value) {
    return $Value -match '\((Group Policy|Gruppenrichtlinie)\)'
}

function Get-PlainValue([string]$Value) {
    return ($Value -replace '\s*\([^)]*\)\s*$', '').Trim()
}

function Get-ServiceDetails {
    param([System.ServiceProcess.ServiceController]$Service)
    if (-not $Service) { return (T 'notInstalled') }
    return "$($Service.Status) | $($Service.StartType)"
}

function New-Check([string]$Key, [string]$Status, [string]$Details) {
    [pscustomobject]@{ Check = (T $Key); Status = $Status; Details = $Details }
}

function Get-Checks {
    $adapter = Get-ActiveAdapter
    $teredo = Get-TeredoText
    $ipV6Binding = Get-NetAdapterBinding -Name $adapter.Name -ComponentID ms_tcpip6 -ErrorAction SilentlyContinue
    $dns = Get-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -ErrorAction SilentlyContinue
    $dnsValues = @($dns.ServerAddresses | Where-Object { $_ })
    $ipHelper = Get-Service iphlpsvc -ErrorAction SilentlyContinue
    $gaming = Get-Service GamingServices -ErrorAction SilentlyContinue
    $xbox = Get-Service XboxNetApiSvc -ErrorAction SilentlyContinue
    $teredoRules = @(Get-NetFirewallRule -DisplayName '*Teredo*' -ErrorAction SilentlyContinue |
        Where-Object { $_.Enabled -eq 'True' -and $_.Action -eq 'Allow' })
    $virtual = @(Get-NetAdapterBinding -Name $adapter.Name -ErrorAction SilentlyContinue |
        Where-Object { $_.Enabled -and $_.ComponentID -match 'vbox|tap|vpn|lwf' })

    $serverRaw = Get-TeredoValue $teredo @('Servername', 'Server Name')
    $portRaw = Get-TeredoValue $teredo @('Clientport', 'Client Port')
    $typeRaw = Get-TeredoValue $teredo @('Typ', 'Type')
    $state = Get-TeredoValue $teredo @('Status', 'State', 'Zustand')

    $type = Get-PlainValue $typeRaw
    $server = Get-PlainValue $serverRaw
    $port = Get-PlainValue $portRaw
    $typeByPolicy = Test-IsPolicyValue $typeRaw
    $shownType = if ($type) { $type } else { T 'notDetected' }

    $dnsOk = ($dnsValues -contains $DnsV4[0]) -and ($dnsValues -contains $DnsV6[0])
    $typeOk = $type -eq 'enterpriseclient'
    $stateOk = $state -match '^(qualified|qualifiziert)$'
    $serverOk = $server -eq $TargetTeredoServer
    $portOk = $port -match 'unspecified|default|nicht angegeben|standard'

    $typeDetails = if ($typeOk -and $typeByPolicy) { T 'det.typeOkGpo' $type }
        elseif ($typeOk) { T 'det.typeOk' $type }
        elseif ($typeByPolicy) { T 'det.typeBadGpo' $shownType }
        else { T 'det.typeBad' $shownType }

    @(
        New-Check 'chk.adapter' $(if ($adapter.Status -eq 'Up') { 'OK' } else { 'FAIL' }) "$($adapter.Name) | $($adapter.LinkSpeed)"
        New-Check 'chk.ipv6' $(if ($ipV6Binding.Enabled) { 'OK' } else { 'FAIL' }) $(if ($ipV6Binding.Enabled) { T 'active' } else { T 'disabled' })
        New-Check 'chk.dns' $(if ($dnsOk) { 'OK' } else { 'INFO' }) $(if ($dnsOk) { $dnsValues -join ', ' } else { T 'det.dnsOther' ($dnsValues -join ', ') })
        New-Check 'chk.teredoType' $(if ($typeOk) { 'OK' } else { 'FAIL' }) $typeDetails
        New-Check 'chk.teredoState' $(if ($stateOk) { 'OK' } else { 'INFO' }) $(if (-not $state) { T 'notDetected' } elseif ($state -match 'dormant|ruhend') { T 'det.stateHint' $state } else { $state })
        New-Check 'chk.teredoServer' $(if ($serverOk) { 'OK' } else { 'INFO' }) $(if ($serverOk) { $serverRaw } else { T 'det.serverBad' $serverRaw $TargetTeredoServer })
        New-Check 'chk.teredoPort' $(if ($portOk) { 'OK' } else { 'INFO' }) $(if ($portOk) { $portRaw } else { T 'det.portBad' $portRaw })
        New-Check 'chk.iphlp' $(if ($ipHelper -and $ipHelper.Status -eq 'Running') { 'OK' } else { 'FAIL' }) (Get-ServiceDetails $ipHelper)
        New-Check 'chk.gaming' $(if ($gaming -and $gaming.Status -eq 'Running') { 'OK' } else { 'INFO' }) (Get-ServiceDetails $gaming)
        New-Check 'chk.xbox' $(if ($xbox -and $xbox.Status -eq 'Running') { 'OK' } else { 'INFO' }) (Get-ServiceDetails $xbox)
        New-Check 'chk.firewall' $(if ($teredoRules.Count -ge 1) { 'OK' } else { 'INFO' }) (T 'det.firewall' $teredoRules.Count)
        New-Check 'chk.filters' $(if ($virtual.Count -eq 0) { 'OK' } else { 'INFO' }) $(if ($virtual) { $virtual.DisplayName -join ', ' } else { T 'none' })
        New-Check 'chk.router' 'INFO' (T 'det.router')
    )
}

function Show-Checks {
    Clear-Host
    Write-Host (T 'title' $ToolVersion) -ForegroundColor Cyan
    Write-Host (T 'intro')
    if (-not $script:IsAdmin) {
        Write-Host (T 'diagOnly') -ForegroundColor Yellow
    }
    Write-Host (T 'legend') -ForegroundColor DarkGray
    Write-Host ''
    foreach ($check in Get-Checks) {
        $color = switch ($check.Status) { 'OK' { 'Green' } 'FAIL' { 'Red' } default { 'Yellow' } }
        $symbol = switch ($check.Status) { 'OK' { '[OK]' } 'FAIL' { '[X] ' } default { '[!] ' } }
        Write-Host ($symbol + ' ' + $check.Check.PadRight(36) + ' ' + $check.Details) -ForegroundColor $color
    }
    Write-Host ''
}

function Confirm([string]$Question) {
    (Read-Host "$Question $(T 'yesNo')") -match '^(j|ja|y|yes)$'
}

# ---------------------------------------------------------------------------
# Aktionen / Actions
# ---------------------------------------------------------------------------
function Enable-IPv6 {
    if (-not (Require-Admin)) { return }
    $adapter = Get-ActiveAdapter
    if (Confirm (T 'confirmIpv6' $adapter.Name)) {
        Enable-NetAdapterBinding -Name $adapter.Name -ComponentID ms_tcpip6
        Write-Host (T 'doneIpv6') -ForegroundColor Green
    }
}

function Set-CloudflareDns {
    if (-not (Require-Admin)) { return }
    $adapter = Get-ActiveAdapter
    if (Confirm (T 'confirmDns' $adapter.Name)) {
        Set-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -ServerAddresses $DnsV4
        netsh interface ipv6 set dnsservers interface=$($adapter.ifIndex) static $($DnsV6[0]) primary | Out-Null
        netsh interface ipv6 add dnsservers interface=$($adapter.ifIndex) $($DnsV6[1]) index=2 | Out-Null
        Clear-DnsClientCache
        Write-Host (T 'doneDns') -ForegroundColor Green
    }
}

function Set-RecommendedTeredo {
    if (-not (Require-Admin)) { return }
    if (Test-IsPolicyValue (Get-TeredoText)) {
        Write-Host (T 'gpoWarn') -ForegroundColor Yellow
    }
    if (Confirm (T 'confirmTeredo' $TargetTeredoServer)) {
        netsh interface teredo set state type=enterpriseclient servername=$TargetTeredoServer clientport=default | Out-Null
        Write-Host (T 'doneTeredo') -ForegroundColor Green
    }
}

function Start-RequiredServices {
    if (-not (Require-Admin)) { return }
    if (Confirm (T 'confirmServices')) {
        Set-Service iphlpsvc -StartupType Automatic
        Start-Service iphlpsvc -ErrorAction SilentlyContinue
        @('GamingServices', 'XboxNetApiSvc', 'XblAuthManager') | ForEach-Object {
            if (Get-Service $_ -ErrorAction SilentlyContinue) {
                Start-Service $_ -ErrorAction SilentlyContinue
            }
        }
        Write-Host (T 'doneServices') -ForegroundColor Green
    }
}

function Export-DiagnosticReport {
    $desktop = [Environment]::GetFolderPath('Desktop')
    $folder = Join-Path $desktop 'Forza-Monitor'
    New-Item -ItemType Directory -Path $folder -Force | Out-Null
    $path = Join-Path $folder (T 'rep.file' (Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'))
    $adapter = Get-ActiveAdapter
    $table = Get-Checks | Select-Object `
        @{ Name = (T 'rep.col.check'); Expression = { $_.Check } },
        @{ Name = (T 'rep.col.status'); Expression = { $_.Status } },
        @{ Name = (T 'rep.col.details'); Expression = { $_.Details } }
    $lines = @(
        (T 'rep.title')
        (T 'rep.version' $ToolVersion)
        (T 'rep.time' (Get-Date -Format 'yyyy-MM-dd HH:mm:ss K'))
        "Windows: $([Environment]::OSVersion.VersionString)"
        (T 'rep.adapter' "$($adapter.Name) | $($adapter.InterfaceDescription) | $($adapter.LinkSpeed)")
        ''
        ($table | Format-Table -AutoSize | Out-String -Width 260).TrimEnd()
        ''
        (T 'rep.privacy')
    )
    $lines | Set-Content -Path $path -Encoding UTF8
    Write-Host (T 'rep.saved' $path) -ForegroundColor Green
}

function Start-Monitor {
    $monitor = Join-Path $PackageRoot 'ForzaMonitor.ps1'
    if (-not (Test-Path $monitor)) { throw (T 'monNotFound' $monitor) }
    Start-Process powershell.exe -ArgumentList "-NoProfile -NoExit -ExecutionPolicy Bypass -File `"$monitor`" -Language $script:Lang"
}

# ---------------------------------------------------------------------------
# Hauptmenü / Main menu
# ---------------------------------------------------------------------------
$script:IsAdmin = Test-IsAdmin
while ($true) {
    try {
        Show-Checks
    } catch {
        Write-Host (T 'checkFailed' $_.Exception.Message) -ForegroundColor Red
        Write-Host (T 'checkFailedHow') -ForegroundColor Yellow
    }

    Write-Host (T 'menu') -ForegroundColor Cyan
    Write-Host (T 'menu1')
    Write-Host (T 'menu2')
    Write-Host (T 'menu3')
    Write-Host (T 'menu4')
    Write-Host (T 'menu5')
    Write-Host (T 'menu6')
    if (-not $script:IsAdmin) { Write-Host (T 'menuA') }
    Write-Host (T 'menuL')
    Write-Host (T 'menuR')
    Write-Host (T 'menuQ')
    $choice = Read-Host (T 'choice')
    try {
        switch ($choice.ToUpperInvariant()) {
            '1' { Enable-IPv6; Start-Sleep 1 }
            '2' { Set-CloudflareDns; Start-Sleep 1 }
            '3' { Set-RecommendedTeredo; Start-Sleep 1 }
            '4' { Start-RequiredServices; Start-Sleep 1 }
            '5' { Export-DiagnosticReport; Read-Host (T 'pressEnter') | Out-Null }
            '6' { Start-Monitor }
            'A' { Restart-AsAdmin }
            'L' { $script:Lang = if ($script:Lang -eq 'de') { 'en' } else { 'de' } }
            'Q' { exit }
        }
    } catch {
        Write-Host (T 'actionFailed' $_.Exception.Message) -ForegroundColor Red
        Read-Host (T 'pressEnter') | Out-Null
    }
}
