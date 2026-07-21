Exit code: 0
Wall time: 0.2 seconds
Output:
# Forza Horizon 4 â€“ Netzwerkhelfer fÃ¼r Windows

Ein transparentes Diagnose- und Hilfswerkzeug fÃ¼r **Forza Horizon 4 Online-AbbrÃ¼che** unter Windows 10/11.

Es richtet sich an Spieler, bei denen FH4 keine Horizon-Sitzung beitreten kann oder die Verbindung verliert, obwohl die allgemeine Internetverbindung stabil aussieht.

> Kein offizielles Werkzeug von Playground Games, Forza oder Microsoft. Nutzung auf eigene Verantwortung.

## Was das Tool prÃ¼ft

Beim Start erscheint eine Ã¼bersichtliche PrÃ¼fung. GrÃ¼n bedeutet: Einstellung passt. Rot bedeutet: Einstellung fehlt oder weicht von der empfohlenen Konfiguration ab. Gelb ist ein Hinweis.

- aktiver Netzwerkadapter und IPv6
- DNS-Server (empfohlen: Cloudflare)
- Teredo-Modus, Teredo-Server und automatischer Teredo-Port
- IP-Hilfsdienst, Gaming Services und Xbox-Netzwerkdienst
- Windows-Firewallregeln fÃ¼r Teredo
- aktive VPN- oder Virtualisierungsfilter am Gaming-Adapter

## Was nach BestÃ¤tigung geÃ¤ndert werden kann

Jede Ã„nderung muss einzeln bestÃ¤tigt werden. Das Tool kann:

1. IPv6 am aktiven Adapter aktivieren
2. Cloudflare DNS eintragen: `1.1.1.1`, `1.0.0.1`, `2606:4700:4700::1111`, `2606:4700:4700::1001`
3. Teredo auf `enterpriseclient` mit `win10.ipv6.microsoft.com` und automatischem Clientport setzen
4. benÃ¶tigte Xbox-/Netzwerkdienste starten
5. einen separaten Monitor fÃ¼r einen FH4-Test starten

Das Tool deinstalliert keine Programme, Ã¶ffnet keine Ports manuell und setzt keine Firewall vollstÃ¤ndig zurÃ¼ck.

## Start

1. Die ZIP-Datei herunterladen und vollstÃ¤ndig entpacken.
2. `Start-Forza-Netzwerkhelfer.bat` doppelklicken.
3. Die Windows-Sicherheitsabfrage bestÃ¤tigen.
4. Die angezeigten Punkte prÃ¼fen und bei Bedarf eine Aktion auswÃ¤hlen.
5. FÃ¼r einen Test `5 â€“ Forza Monitor starten` wÃ¤hlen.

Der Monitor schreibt seine Ergebnisse nach `Desktop\Forza-Monitor`. Bei einem Abbruch im Monitorfenster `M` drÃ¼cken; mit `Strg+C` beenden.

## ZusÃ¤tzlich am Router prÃ¼fen

Das Tool kann keine Router-Einstellungen verÃ¤ndern. Bei einer FRITZ!Box sind fÃ¼r den Gaming-PC Ã¼blicherweise diese Einstellungen sinnvoll:

- **Internet â†’ Filter â†’ Listen:** Teredo-Filter deaktiviert
- **Heimnetz â†’ Netzwerk â†’ Gaming-PC:** â€žSelbststÃ¤ndige Portfreigaben fÃ¼r dieses GerÃ¤t erlaubenâ€œ aktiviert

Keinen Exposed Host nur fÃ¼r diesen Zweck einrichten. Manuelle Portfreigaben sind fÃ¼r die Diagnose normalerweise ebenfalls nicht nÃ¶tig.

## Wichtige Hinweise

- Teredo kann im Leerlauf `dormant` anzeigen. Entscheidend ist der Status wÃ¤hrend FH4 online ist; dort sollte es idealerweise `qualified` sein.
- `restricted (port)` bei NAT oder `UPnP: Nein` in der Teredo-Ausgabe ist nicht automatisch ein Fehler.
- Das Tool kann keine Probleme auf den FH4-Servern, beim Microsoft-Konto oder durch andere Software garantieren beheben.
- Vor dem Test VPN-Software, virtuelle Netzwerkadapter und Torrent-Programme schlieÃŸen bzw. deaktivieren.

## Datenschutz

Die PrÃ¼fung lÃ¤uft ausschlieÃŸlich lokal. Der Monitor schreibt CSV-/Textdateien nur auf den eigenen Desktop und lÃ¤dt nichts hoch. Vor dem Teilen von Logdateien bitte Ã¶ffentliche IP-Adressen oder andere persÃ¶nliche Daten kontrollieren und bei Bedarf schwÃ¤rzen.

## RÃ¼ckmeldungen und Fehlerberichte

Bitte bei einer RÃ¼ckmeldung angeben:

- Windows-Version
- Steam- oder Microsoft-Store-Version von FH4
- Screenshot der Helfer-Ãœbersicht
- die letzte Monitor-CSV und Textdatei
- Zeitpunkt und genauer Wortlaut der FH4-Fehlermeldung

## Lizenz

Dieses Projekt steht unter der MIT-Lizenz. Details in [LICENSE](LICENSE).

