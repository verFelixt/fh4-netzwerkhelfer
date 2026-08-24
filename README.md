# Forza Horizon 4 – Netzwerkhelfer für Windows

Ein transparentes Diagnose- und Hilfswerkzeug für **Forza Horizon 4 Online-Abbrüche** unter Windows 10/11.

Es richtet sich an Spieler, bei denen FH4 keiner Horizon-Sitzung beitreten kann oder die Verbindung verliert, obwohl die allgemeine Internetverbindung stabil aussieht.

> Kein offizielles Werkzeug von Playground Games, Forza oder Microsoft. Nutzung auf eigene Verantwortung.

## Neu in Version 1.1.3

- beide PowerShell-Dateien werden mit UTF-8-BOM ausgeliefert, damit Windows PowerShell 5.1 deutsche Umlaute und `ß` korrekt darstellt

## Seit Version 1.1.2

- der Windows-Starter verwendet `-NoExit`, damit das PowerShell-Fenster bei einem unerwarteten Skriptende offen bleibt und die Fehlermeldung sichtbar ist

## Seit Version 1.1.1

- Diagnose, Bericht und Monitor starten jetzt ohne erzwungene Administrator-Neustartschleife
- Reparaturaktionen erklären bei fehlenden Rechten klar, wie der Helfer als Administrator neu gestartet wird
- Fehler beim automatischen Administrator-Neustart schließen das Programm nicht mehr

## Seit Version 1.1.0

- zuverlässigere Auswertung deutscher und englischer Teredo-Ausgaben
- zusätzlicher Teredo-Status in der Übersicht
- robusterer Monitor mit korrekt escaped CSV-Feldern
- Desktop-Pfad wird über Windows ermittelt und funktioniert dadurch auch bei umgeleiteten Ordnern
- separater Diagnosebericht ohne absichtlich ermittelte öffentliche IP-Adresse
- verständliche Fehlermeldungen, wenn einzelne Dienste oder Dateien fehlen

## Was das Tool prüft

Beim Start erscheint eine übersichtliche Prüfung. Grün bedeutet: Einstellung passt. Rot bedeutet: Einstellung fehlt oder weicht von der empfohlenen Konfiguration ab. Gelb ist ein Hinweis.

- aktiver Netzwerkadapter und IPv6
- DNS-Server (optional empfohlen: Cloudflare)
- Teredo-Modus, Status, Server und automatischer Teredo-Port
- IP-Hilfsdienst, Gaming Services und Xbox-Netzwerkdienst
- Windows-Firewallregeln für Teredo
- aktive VPN- oder Virtualisierungsfilter am Gaming-Adapter

## Was nach Bestätigung geändert werden kann

Jede Änderung muss einzeln bestätigt werden. Das Tool kann:

1. IPv6 am aktiven Adapter aktivieren
2. Cloudflare DNS eintragen: `1.1.1.1`, `1.0.0.1`, `2606:4700:4700::1111`, `2606:4700:4700::1001`
3. Teredo auf `enterpriseclient` mit `win10.ipv6.microsoft.com` und automatischem Clientport setzen
4. benötigte Xbox-/Netzwerkdienste starten

Das Tool deinstalliert keine Programme, öffnet keine Ports manuell und setzt die Firewall nicht vollständig zurück.

## Start

1. Die ZIP-Datei herunterladen und vollständig entpacken.
2. `Start-Forza-Netzwerkhelfer.bat` doppelklicken.
3. Die Windows-Sicherheitsabfrage bestätigen.
4. Die angezeigten Punkte prüfen und bei Bedarf eine Aktion auswählen.
5. Mit Aktion `5` bei Bedarf einen Diagnosebericht speichern.
6. Für einen Verbindungstest Aktion `6 – Forza Monitor starten` wählen.

Diagnoseberichte und Monitorprotokolle werden im Ordner `Forza-Monitor` auf dem Windows-Desktop gespeichert. Bei einem Abbruch im Monitorfenster `M` drücken; mit `Strg+C` beenden.

## Zusätzlich am Router prüfen

Das Tool kann keine Router-Einstellungen verändern. Bei einer FRITZ!Box sind für den Gaming-PC üblicherweise diese Einstellungen sinnvoll:

- **Internet → Filter → Listen:** Teredo-Filter deaktiviert
- **Heimnetz → Netzwerk → Gaming-PC:** „Selbstständige Portfreigaben für dieses Gerät erlauben“ aktiviert

Keinen Exposed Host nur für diesen Zweck einrichten. Manuelle Portfreigaben sind für die Diagnose normalerweise ebenfalls nicht nötig.

## Wichtige Hinweise

- Teredo kann im Leerlauf `dormant` anzeigen. Entscheidend ist der Status, während FH4 online ist; dort sollte es idealerweise `qualified` sein.
- `restricted (port)` bei NAT oder `UPnP: Nein` in der Teredo-Ausgabe ist nicht automatisch ein Fehler.
- Cloudflare DNS ist eine optionale Diagnosemaßnahme. Wenn dein vorhandener DNS zuverlässig funktioniert, musst du ihn nicht ändern.
- Das Tool kann Probleme auf den FH4-Servern, beim Microsoft-Konto oder durch andere Software nicht garantiert beheben.
- Vor dem Test VPN-Software, virtuelle Netzwerkadapter und Torrent-Programme schließen bzw. deaktivieren.

## Datenschutz

Die Prüfung läuft ausschließlich lokal. Der Helfer schreibt Text-/CSV-Dateien nur auf den eigenen Desktop und lädt nichts hoch. Der Diagnosebericht ermittelt absichtlich keine öffentliche IP-Adresse. Andere technische Angaben können trotzdem Rückschlüsse auf das eigene System erlauben; vor dem Teilen bitte kontrollieren und bei Bedarf schwärzen.

## Rückmeldungen und Fehlerberichte

Bitte bei einer Rückmeldung angeben:

- Windows-Version
- Steam- oder Microsoft-Store-Version von FH4
- Screenshot der Helfer-Übersicht oder Diagnosebericht
- die letzte Monitor-CSV
- Zeitpunkt und genauer Wortlaut der FH4-Fehlermeldung

## Lizenz

Dieses Projekt steht unter der MIT-Lizenz. Details in [LICENSE](LICENSE).

