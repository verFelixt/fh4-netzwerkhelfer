Exit code: 0
Wall time: 0.2 seconds
Output:
# Forza Horizon 4 - kompakter Verbindungsmonitor
# Strg+C beendet die Aufzeichnung. Mit M markierst du einen Abbruch.
$folder = Join-Path $env:USERPROFILE 'Desktop\Forza-Monitor'
New-Item -ItemType Directory -Path $folder -Force | Out-Null
$stamp = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'
$csv = Join-Path $folder "ForzaMonitor_$stamp.csv"
"Zeit;Ereignis;Gateway;Internet;DNS_Xbox;Teredo_Status;Teredo_Server;Teredo_Fehler" | Set-Content $csv -Encoding utf8
Write-Host 'Forza Monitor laeuft. Bei Abbruch M druecken; mit Strg+C beenden.' -ForegroundColor Green
Write-Host "Protokoll: $csv"
function PingState([string]$Target) { try { if(Test-Connection $Target -Count 1 -Quiet -ErrorAction Stop){'OK'}else{'FEHLER'} } catch {'FEHLER'} }
function DnsState([string]$Name) { try { Resolve-DnsName $Name -Type A -ErrorAction Stop | Out-Null; 'OK' } catch {'FEHLER'} }
function Teredo { $raw=netsh interface teredo show state 2>&1 | Out-String; [pscustomobject]@{Raw=$raw;Status=([regex]::Match($raw,'(?im)^\\s*(Status|State)\\s*:\\s*(.+)$').Groups[2].Value.Trim());Server=([regex]::Match($raw,'(?im)^\\s*(Servername|Server Name)\\s*:\\s*(.+)$').Groups[2].Value.Trim());Error=([regex]::Match($raw,'(?im)^\\s*Fehler\\s*:\\s*(.+)$').Groups[1].Value.Trim())} }
try { while($true) { $marker=''; if([Console]::KeyAvailable){$key=[Console]::ReadKey($true);if($key.Key -eq 'M'){$marker='ABBRUCH_MARKIERT'}}; $route=Get-NetRoute -DestinationPrefix '0.0.0.0/0'|Where-Object {$_.NextHop -ne '0.0.0.0'}|Sort-Object RouteMetric|Select-Object -First 1; $t=Teredo; $line=@((Get-Date -Format 'yyyy-MM-dd HH:mm:ss'),$marker,$route.NextHop,(PingState '1.1.1.1'),(DnsState 'xboxlive.com'),$t.Status,$t.Server,$t.Error)-join ';'; Add-Content $csv $line -Encoding utf8; $color=if($t.Status -match '^qualified$'){'Green'}else{'Yellow'}; Write-Host ((Get-Date -Format 'HH:mm:ss') + " | Internet: $(PingState '1.1.1.1') | Teredo: $($t.Status) $marker") -ForegroundColor $color; Start-Sleep 1 } } finally { Write-Host "Monitor beendet. Log: $csv" -ForegroundColor Yellow }

