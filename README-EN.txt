FORZA HORIZON 4 - NETWORK HELPER 1.2.0
======================================

Purpose
-------
This package helps with FH4 online disconnects that happen even though your
internet connection works. It checks Windows networking, IPv6, DNS, Teredo,
Xbox services and the Windows Firewall. Every change is explained and has to
be confirmed with Y.

The helper uses your Windows display language (German or English).
Press L in the menu to switch the language.

Start
-----
1. Extract the ZIP.
2. Right-click Start-Forza-Netzwerkhelfer.bat and choose "Run as administrator".
3. Confirm the Windows security prompt with Yes.
4. In the overview: [OK] = fine, [X] = missing, [!] = note.
5. Type the number of the action you want, press Enter and confirm with Y.
   Example: 3 = set recommended Teredo configuration.
6. Optional: action 5 saves a diagnostic report.
7. Then choose action 6 to start the monitor.

Without administrator rights the helper runs in diagnose-only mode. Report
and monitor still work. For repairs choose A or start the batch file as
administrator.

Recommended configuration
-------------------------
- IPv6 enabled on the active gaming adapter
- Optional Cloudflare DNS: 1.1.1.1 / 1.0.0.1 and
  2606:4700:4700::1111 / ::1001
- Teredo: enterpriseclient, server win10.ipv6.microsoft.com,
  client port automatic (unspecified)
- IP Helper service enabled and running
- No active VPN or virtualization filters on the gaming adapter

Teredo and Group Policy
-----------------------
If Teredo was set with gpedit.msc, netsh shows e.g.
"enterpriseclient (Group Policy)". That is fine.
If the policy forces a different value, action 3 cannot override it. Change it
in gpedit.msc: Computer Configuration > Administrative Templates > Network >
TCPIP Settings > IPv6 Transition Technologies.

What the helper does NOT change automatically
---------------------------------------------
- Router settings. On a FRITZ!Box please check:
  Internet > Filters > Lists > Teredo filter OFF.
  Home Network > Network > gaming PC > Permit independent port sharing ON.
  On other routers: UPnP on, no Teredo/IPv6 tunnel filter.
- It does not uninstall programs and does not fully reset the firewall.

Diagnostic report and monitor
-----------------------------
Reports and monitor CSV files are saved in the Forza-Monitor folder on your
Windows desktop. Press M in the monitor window when FH4 disconnects.
Ctrl+C stops the monitor. The report intentionally does not collect your
public IP address and nothing is uploaded.

Note
----
This tool uses built-in Windows features and is intended for Windows 10/11.
It cannot guarantee a stable internet connection or FH4 server availability.
If errors persist, send the diagnostic report and the CSV together with your
support ID to Forza Support.
