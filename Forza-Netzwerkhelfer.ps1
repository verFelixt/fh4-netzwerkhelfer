# Forza Horizon 4 Netzwerkhelfer 1.1.0
# Interaktiver, lokaler Prüfer. Alle Änderungen erfordern eine Bestätigung.

$ErrorActionPreference = 'Stop'
$ToolVersion = '1.1.0'
$TargetTeredoServer = 'win10.ipv6.microsoft.com'
$DnsV4 = @('1.1.1.1', '1.0.0.1')
$DnsV6 = @('2606:4700:4700::1111', '2606:4700:4700::1001')
$PackageRoot = Split-Path -Parent $PSCommandPath

function Ensure-Admin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host 'Administratorrechte werden für optionale Reparaturen benötigt.' -ForegroundColor Yellow
        $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
        Start-Process powershell.exe -Verb RunAs -ArgumentList $arguments
        exit
    }
}

function Get-ActiveAdapter {
    $route = Get-NetRoute -DestinationPrefix '0.0.0.0/0' -ErrorAction Stop |
        Where-Object { $_.NextHop -ne '0.0.0.0' -and $_.State -eq 'Alive' } |
        Sort-Object RouteMetric, InterfaceMetric | Select-Object -First 1
    if (-not $route) { throw 'Keine aktive IPv4-Standardroute gefunden.' }
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

function Get-ServiceDetails {
    param([System.ServiceProcess.ServiceController]$Service)
    if (-not $Service) { return 'nicht installiert' }
    return "$($Service.Status) | $($Service.StartType)"
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
    $server = Get-TeredoValue $teredo @('Servername', 'Server Name')
    $port = Get-TeredoValue $teredo @('Clientport', 'Client Port')
    $type = Get-TeredoValue $teredo @('Typ', 'Type')
    $state = Get-TeredoValue $teredo @('Status', 'State', 'Zustand')

    @(
        [pscustomobject]@{Pruefung='Aktiver Gaming-Adapter'; Status=if($adapter.Status -eq 'Up'){'OK'}else{'FEHLT'}; Details="$($adapter.Name) | $($adapter.LinkSpeed)"}
        [pscustomobject]@{Pruefung='IPv6 am Gaming-Adapter'; Status=if($ipV6Binding.Enabled){'OK'}else{'FEHLT'}; Details=if($ipV6Binding.Enabled){'aktiv'}else{'deaktiviert'}}
        [pscustomobject]@{Pruefung='Cloudflare DNS (IPv4/IPv6)'; Status=if(($dnsValues -contains $DnsV4[0]) -and ($dnsValues -contains $DnsV6[0])){'OK'}else{'HINWEIS'}; Details=($dnsValues -join ', ')}
        [pscustomobject]@{Pruefung='Teredo-Modus'; Status=if($type -eq 'enterpriseclient'){'OK'}else{'FEHLT'}; Details=$type}
        [pscustomobject]@{Pruefung='Teredo-Status'; Status=if($state -match '^(qualified|qualifiziert)$'){'OK'}else{'HINWEIS'}; Details=if($state){$state}else{'nicht erkannt'}}
        [pscustomobject]@{Pruefung='Teredo-Server'; Status=if($server -eq $TargetTeredoServer){'OK'}else{'HINWEIS'}; Details=$server}
        [pscustomobject]@{Pruefung='Teredo-Clientport'; Status=if($port -match 'unspecified|default|nicht angegeben|standard'){'OK'}else{'HINWEIS'}; Details=$port}
        [pscustomobject]@{Pruefung='IP-Hilfsdienst'; Status=if($ipHelper -and $ipHelper.Status -eq 'Running'){'OK'}else{'FEHLT'}; Details=Get-ServiceDetails $ipHelper}
        [pscustomobject]@{Pruefung='Gaming Services'; Status=if(-not $gaming){'HINWEIS'}elseif($gaming.Status -eq 'Running'){'OK'}else{'HINWEIS'}; Details=Get-ServiceDetails $gaming}
        [pscustomobject]@{Pruefung='Xbox Netzwerkdienst'; Status=if(-not $xbox){'HINWEIS'}elseif($xbox.Status -eq 'Running'){'OK'}else{'HINWEIS'}; Details=Get-ServiceDetails $xbox}
        [pscustomobject]@{Pruefung='Windows-Firewall: Teredo'; Status=if($teredoRules.Count -ge 1){'OK'}else{'HINWEIS'}; Details="$($teredoRules.Count) erlaubende Regel(n)"}
        [pscustomobject]@{Pruefung='Aktive VPN-/Virtualisierungsfilter'; Status=if($virtual.Count -eq 0){'OK'}else{'HINWEIS'}; Details=if($virtual){($virtual.DisplayName -join ', ')}else{'keine'}}
        [pscustomobject]@{Pruefung='FRITZ!Box (manuell prüfen)'; Status='HINWEIS'; Details='Teredo-Filter aus; selbstständige Portfreigaben für den PC an'}
    )
}

function Show-Checks {
    Clear-Host
    Write-Host "FORZA HORIZON 4 - NETZWERKHELFER v$ToolVersion" -ForegroundColor Cyan
    Write-Host 'Die Prüfung ist lokal. Änderungen erfolgen nur nach deiner Bestätigung.'
    Write-Host ''
    foreach ($check in Get-Checks) {
        $color = switch ($check.Status) { 'OK' {'Green'} 'FEHLT' {'Red'} default {'Yellow'} }
        $symbol = switch ($check.Status) { 'OK' {'[OK]'} 'FEHLT' {'[X] '} default {'[!] '} }
        Write-Host ($symbol + ' ' + $check.Pruefung.PadRight(36) + ' ' + $check.Details) -ForegroundColor $color
    }
    Write-Host ''
}

function Confirm([string]$Question) {
    (Read-Host "$Question (J/N)") -match '^(j|ja|y|yes)$'
}

function Enable-IPv6 {
    $adapter = Get-ActiveAdapter
    if (Confirm "IPv6 auf '$($adapter.Name)' aktivieren?") {
        Enable-NetAdapterBinding -Name $adapter.Name -ComponentID ms_tcpip6
        Write-Host 'IPv6 wurde aktiviert.' -ForegroundColor Green
    }
}

function Set-CloudflareDns {
    $adapter = Get-ActiveAdapter
    if (Confirm "DNS auf Cloudflare am Adapter '$($adapter.Name)' setzen?") {
        Set-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -ServerAddresses $DnsV4
        netsh interface ipv6 set dnsservers interface=$($adapter.ifIndex) static $($DnsV6[0]) primary | Out-Null
        netsh interface ipv6 add dnsservers interface=$($adapter.ifIndex) $($DnsV6[1]) index=2 | Out-Null
        Clear-DnsClientCache
        Write-Host 'DNS wurde auf Cloudflare gesetzt.' -ForegroundColor Green
    }
}

function Set-RecommendedTeredo {
    if (Confirm "Teredo auf enterpriseclient mit '$TargetTeredoServer' und automatischem Port setzen?") {
        netsh interface teredo set state type=enterpriseclient servername=$TargetTeredoServer clientport=default | Out-Null
        Write-Host 'Teredo-Konfiguration gesetzt.' -ForegroundColor Green
    }
}

function Start-RequiredServices {
    if (Confirm 'IP-Hilfsdienst, Gaming Services und Xbox Netzwerkdienst starten?') {
        Set-Service iphlpsvc -StartupType Automatic
        Start-Service iphlpsvc -ErrorAction SilentlyContinue
        @('GamingServices', 'XboxNetApiSvc', 'XblAuthManager') | ForEach-Object {
            if (Get-Service $_ -ErrorAction SilentlyContinue) {
                Start-Service $_ -ErrorAction SilentlyContinue
            }
        }
        Write-Host 'Dienste wurden gestartet, soweit Windows dies erlaubt.' -ForegroundColor Green
    }
}

function Export-DiagnosticReport {
    $desktop = [Environment]::GetFolderPath('Desktop')
    $folder = Join-Path $desktop 'Forza-Monitor'
    New-Item -ItemType Directory -Path $folder -Force | Out-Null
    $path = Join-Path $folder ("Forza-Diagnose_{0}.txt" -f (Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'))
    $adapter = Get-ActiveAdapter
    $lines = @(
        'FORZA HORIZON 4 - DIAGNOSEBERICHT'
        "Netzwerkhelfer: v$ToolVersion"
        "Zeit: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss K')"
        "Windows: $([Environment]::OSVersion.VersionString)"
        "Adapter: $($adapter.Name) | $($adapter.InterfaceDescription) | $($adapter.LinkSpeed)"
        ''
        (Get-Checks | Format-Table Pruefung, Status, Details -AutoSize | Out-String -Width 220).TrimEnd()
        ''
        'Hinweis: Der Bericht enthält keine absichtlich ermittelte öffentliche IP-Adresse und wird nicht hochgeladen.'
    )
    $lines | Set-Content -Path $path -Encoding UTF8
    Write-Host "Diagnosebericht gespeichert: $path" -ForegroundColor Green
}

function Start-Monitor {
    $monitor = Join-Path $PackageRoot 'ForzaMonitor.ps1'
    if (-not (Test-Path $monitor)) { throw "Monitor nicht gefunden: $monitor" }
    Start-Process powershell.exe -ArgumentList "-NoProfile -NoExit -ExecutionPolicy Bypass -File `"$monitor`""
}

Ensure-Admin
while ($true) {
    try {
        Show-Checks
    } catch {
        Write-Host "Prüfung fehlgeschlagen: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host 'Bitte Netzwerkverbindung und Windows-Netzwerkdienste prüfen.' -ForegroundColor Yellow
    }

    Write-Host 'Aktionen:' -ForegroundColor Cyan
    Write-Host '  1  IPv6 aktivieren'
    Write-Host '  2  DNS auf Cloudflare setzen'
    Write-Host '  3  Empfohlene Teredo-Konfiguration setzen'
    Write-Host '  4  Xbox-/Netzwerkdienste starten'
    Write-Host '  5  Diagnosebericht speichern'
    Write-Host '  6  Forza Monitor starten'
    Write-Host '  R  Prüfung aktualisieren'
    Write-Host '  Q  Beenden'
    $choice = Read-Host 'Auswahl'
    try {
        switch ($choice.ToUpperInvariant()) {
            '1' { Enable-IPv6; Start-Sleep 1 }
            '2' { Set-CloudflareDns; Start-Sleep 1 }
            '3' { Set-RecommendedTeredo; Start-Sleep 1 }
            '4' { Start-RequiredServices; Start-Sleep 1 }
            '5' { Export-DiagnosticReport; Read-Host 'Weiter mit Eingabetaste' | Out-Null }
            '6' { Start-Monitor }
            'Q' { exit }
        }
    } catch {
        Write-Host "Aktion fehlgeschlagen: $($_.Exception.Message)" -ForegroundColor Red
        Read-Host 'Weiter mit Eingabetaste' | Out-Null
    }
}

