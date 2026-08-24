FORZA HORIZON 4 - NETZWERKHELFER 1.1.2
=======================================

Zweck
-----
Dieses Paket hilft bei FH4-Onlineabbruechen, die trotz funktionierendem Internet
auftreten. Es prueft Windows-Netzwerk, IPv6, DNS, Teredo, Xbox-Dienste und die
Windows-Firewall. Alle Aenderungen werden einzeln erklaert und muessen mit J
bestaetigt werden.

Start
-----
1. ZIP entpacken.
2. Start-Forza-Netzwerkhelfer.bat doppelklicken.
3. Die Windows-Sicherheitsabfrage mit Ja bestaetigen.
4. In der Uebersicht gilt: [OK] = passt, [X] = fehlt, [!] = Hinweis.
5. Nur die gewuenschte Aktion auswaehlen und mit J bestaetigen.
6. Optional Aktion 5 waehlen, um einen Diagnosebericht zu speichern.
7. Anschliessend Aktion 6 waehlen, um den Monitor zu starten.

Der Helfer startet zunaechst auch ohne Administratorrechte. Diagnosebericht und
Monitor funktionieren im Nur-Diagnose-Modus. Fuer Reparaturaktionen A waehlen
oder die Batch-Datei per Rechtsklick als Administrator starten.

Seit Version 1.1.2 bleibt das PowerShell-Fenster bei einem unerwarteten Ende
offen, damit die Fehlermeldung gelesen werden kann.

Empfohlene Konfiguration
------------------------
- IPv6 am aktiven Gaming-Adapter aktiviert
- Optional Cloudflare DNS: 1.1.1.1 / 1.0.0.1 und
  2606:4700:4700::1111 / ::1001
- Teredo: enterpriseclient, Server win10.ipv6.microsoft.com,
  Clientport automatisch (unspecified)
- IP-Hilfsdienst aktiv und gestartet
- Keine aktiven VPN- oder Virtualisierungsfilter am Gaming-Adapter

Was der Helfer NICHT automatisch aendert
-----------------------------------------
- FRITZ!Box-Einstellungen. Dort bitte pruefen:
  Internet > Filter > Listen > Teredo-Filter AUS.
  Heimnetz > Netzwerk > Gaming-PC > Selbststaendige Portfreigaben erlauben EIN.
- Er deinstalliert keine Programme und setzt die Firewall nicht komplett zurueck.

Diagnosebericht und Monitor
---------------------------
Diagnoseberichte und Monitor-CSV-Dateien landen im Ordner Forza-Monitor auf dem
Windows-Desktop. Der Desktop-Pfad wird automatisch ueber Windows ermittelt.
Bei einem FH4-Abbruch im Monitorfenster M druecken. Mit Strg+C wird beendet.
Der Bericht ermittelt absichtlich keine oeffentliche IP-Adresse und nichts wird
automatisch hochgeladen.

Hinweis
-------
Dieses Werkzeug nutzt Windows-Bordmittel und ist fuer Windows 10/11 gedacht.
Eine stabile Internetverbindung oder FH4-Serververfuegbarkeit kann es nicht
garantieren. Bei anhaltenden Fehlern den Diagnosebericht und die erzeugte CSV
zusammen mit der Support-ID an den Forza-Support geben.

