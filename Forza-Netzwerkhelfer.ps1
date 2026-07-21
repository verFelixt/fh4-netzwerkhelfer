Exit code: 0
Wall time: 0.2 seconds
Output:
# Forza Horizon 4 Netzwerkhelfer
# Interaktiver, lokaler Pruefer. Alle Aenderungen erfordern eine Bestaetigung.

$ErrorActionPreference = 'Stop'
$TargetTeredoServer = 'win10.ipv6.microsoft.com'
$DnsV4 = @('1.1.1.1','1.0.0.1')
$DnsV6 = @('2606:4700:4700::1111','2606:4700:4700::1001')
$PackageRoot = Split-Path -Parent $PSCommandPath

function Ensure-Admin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host 'Administratorrechte werden fuer optionale Reparaturen benoetigt.' -ForegroundColor Yellow
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

function Get-TeredoText { (netsh interface teredo show state 2>&1 | Out-String) }

function Get-TeredoValue {
    param([string]$Text,[string[]]$Labels)
    foreach ($label in $Labels) {
        $match = [regex]::Match($Text, "(?im)^\s*$([regex]::Escape($label))\s*:\s*(.+)$")
        if ($match.Success) { return $match.Groups[1].Value.Trim() }
    }
    return ''
}

function Get-Checks {
    $adapter = Get-ActiveAdapter
    $teredo = Get-TeredoText
    $ipV6Binding = Get-NetAdapterBinding -Name $adapter.Name -ComponentID ms_tcpip6 -ErrorAction SilentlyContinue
    $dns = Get-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -ErrorAction SilentlyContinue
    $dnsValues = @($dns.ServerAddresses | ForEach-Object { $_ })
    $ipHelper = Get-Service iphlpsvc -ErrorAction SilentlyContinue
    $gaming = Get-Service GamingServices -ErrorAction SilentlyContinue
    $xbox = Get-Service XboxNetApiSvc -ErrorAction SilentlyContinue
    $teredoRules = @(Get-NetFirewallRule -DisplayName '*Teredo*' -ErrorAction SilentlyContinue | Where-Object { $_.Enabled -eq 'True' -and $_.Action -eq 'Allow' })
    $virtual = @(Get-NetAdapterBinding -Name $adapter.Name -ErrorAction SilentlyContinue | Where-Object { $_.Enabled -and $_.ComponentID -match 'vbox|tap|vpn|lwf' })
    $server = Get-TeredoValue $teredo @('Servername','Server Name')
    $port = Get-TeredoValue $teredo @('Clientport','Client Port')
    $type = Get-TeredoValue $teredo @('Typ','Type')

    @(
        [pscustomobject]@{Pruefung='Aktiver Gaming-Adapter'; Status=if($adapter.Status -eq 'Up'){'OK'}else{'FEHLT'}; Details="$($adapter.Name) | $($adapter.LinkSpeed)"}
        [pscustomobject]@{Pruefung='IPv6 am Gaming-Adapter'; Status=if($ipV6Binding.Enabled){'OK'}else{'FEHLT'}; Details=if($ipV6Binding.Enabled){'aktiv'}else{'deaktiviert'}}
        [pscustomobject]@{Pruefung='Cloudflare DNS (IPv4/IPv6)'; Status=if(($dnsValues -contains $DnsV4[0]) -and ($dnsValues -contains $DnsV6[0])){'OK'}else{'HINWEIS'}; Details=($dnsValues -join ', ')}
        [pscustomobject]@{Pruefung='Teredo-Modus'; Status=if($type -eq 'enterpriseclient'){'OK'}else{'FEHLT'}; Details=$type}
        [pscustomobject]@{Pruefung='Teredo-Server'; Status=if($server -eq $TargetTeredoServer){'OK'}else{'HINWEIS'}; Details=$server}
        [pscustomobject]@{Pruefung='Teredo-Clientport'; Status=if($port -match 'unspecified|default'){'OK'}else{'HINWEIS'}; Details=$port}
        [pscustomobject]@{Pruefung='IP-Hilfsdienst'; Status=if($ipHelper.Status -eq 'Running'){'OK'}else{'FEHLT'}; Details="$($ipHelper.Status) | $($ipHelper.StartType)"}
        [pscustomobject]@{Pruefung='Gaming Services'; Status=if($gaming.Status -eq 'Running'){'OK'}else{'HINWEIS'}; Details="$($gaming.Status) | $($gaming.StartType)"}
        [pscustomobject]@{Pruefung='Xbox Netzwerkdienst'; Status=if($xbox.Status -eq 'Running'){'OK'}else{'HINWEIS'}; Details="$($xbox.Status) | $($xbox.StartType)"}
        [pscustomobject]@{Pruefung='Windows-Firewall: Teredo'; Status=if($teredoRules.Count -ge 2){'OK'}else{'HINWEIS'}; Details="$($teredoRules.Count) erlaubende Regel(n)"}
        [pscustomobject]@{Pruefung='Aktive VPN-/Virtualisierungsfilter'; Status=if($virtual.Count -eq 0){'OK'}else{'HINWEIS'}; Details=if($virtual){($virtual.DisplayName -join ', ')}else{'keine'}}
        [pscustomobject]@{Pruefung='FRITZ!Box (manuell pruefen)'; Status='HINWEIS'; Details='Teredo-Filter aus; selbststaendige Portfreigaben fuer den PC an'}
    )
}

function Show-Checks {
    Clear-Host
    Write-Host 'FORZA HORIZON 4 - NETZWERKHELFER' -ForegroundColor Cyan
    Write-Host 'Die Pruefung ist lokal. Aenderungen erfolgen nur nach deiner Bestaetigung.'
    Write-Host ''
    foreach ($check in Get-Checks) {
        $color = switch ($check.Status) { 'OK' {'Green'} 'FEHLT' {'Red'} default {'Yellow'} }
        $symbol = switch ($check.Status) { 'OK' {'[OK]'} 'FEHLT' {'[X] '} default {'[!] '} }
        Write-Host ($symbol + ' ' + $check.Pruefung.PadRight(34) + ' ' + $check.Details) -ForegroundColor $color
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
        Start-Service GamingServices -ErrorAction SilentlyContinue
        Start-Service XboxNetApiSvc -ErrorAction SilentlyContinue
        Start-Service XblAuthManager -ErrorAction SilentlyContinue
        Write-Host 'Dienste wurden gestartet, soweit Windows dies erlaubt.' -ForegroundColor Green
    }
}

function Start-Monitor {
    $monitor = Join-Path $PackageRoot 'ForzaMonitor.ps1'
    Start-Process powershell.exe -ArgumentList "-NoExit -ExecutionPolicy Bypass -File `"$monitor`""
}

Ensure-Admin
while ($true) {
    Show-Checks
    Write-Host 'Aktionen:' -ForegroundColor Cyan
    Write-Host '  1  IPv6 aktivieren'
    Write-Host '  2  DNS auf Cloudflare setzen'
    Write-Host '  3  Empfohlene Teredo-Konfiguration setzen'
    Write-Host '  4  Xbox-/Netzwerkdienste starten'
    Write-Host '  5  Forza Monitor starten'
    Write-Host '  R  Pruefung aktualisieren'
    Write-Host '  Q  Beenden'
    $choice = Read-Host 'Auswahl'
    switch ($choice.ToUpperInvariant()) {
        '1' { Enable-IPv6; Start-Sleep 1 }
        '2' { Set-CloudflareDns; Start-Sleep 1 }
        '3' { Set-RecommendedTeredo; Start-Sleep 1 }
        '4' { Start-RequiredServices; Start-Sleep 1 }
        '5' { Start-Monitor }
        'Q' { exit }
    }
}

