# Forza Horizon 4 – Network Helper for Windows

**English** | [Deutsch](README.de.md)

A transparent diagnostic and helper tool for **Forza Horizon 4 online disconnects** on Windows 10/11.

It is meant for players whose FH4 can't join a Horizon session or keeps losing the connection even though their regular internet connection looks stable.

> Not an official tool from Playground Games, Forza or Microsoft. Use at your own risk.

## Quick start

1. Download the ZIP from the [Releases page](https://github.com/verFelixt/fh4-netzwerkhelfer/releases) and extract it completely.
2. Right-click `Start-Forza-Netzwerkhelfer.bat` → **Run as administrator** (without admin rights only diagnosis works).
3. Check the overview. Red `[X]` entries are what you most likely need to fix.
4. Type the number of an action (e.g. `3` = set recommended Teredo configuration), press Enter, then confirm with `Y`.
5. Press `R` to refresh the checks.

The tool picks its language from your Windows display language (German or English). Press `L` in the menu to switch at any time.

## New in version 1.2.0

- **English language support** for the helper, the monitor and the diagnostic report (automatic, switchable with `L`)
- Fixed a false red `[X]` for the Teredo type when Teredo is configured via **Group Policy** (`enterpriseclient (Group Policy)` is now recognized as correct)
- Clearer messages: deviations now show the current value and which action fixes it
- English README (`README.md`, `README-EN.txt`)

Older changes: see [CHANGELOG in the German README](README.de.md#neu-in-version-120).

## What the tool checks

Green `[OK]` = setting is fine. Red `[X]` = setting is missing or differs from the recommended configuration. Yellow `[!]` = note.

- active network adapter and IPv6
- DNS servers (optionally recommended: Cloudflare)
- Teredo type, state, server and automatic Teredo client port
- IP Helper service, Gaming Services and Xbox Live Networking Service
- Windows Firewall rules for Teredo
- active VPN or virtualization filters on the gaming adapter

## What can be changed after confirmation

Every change has to be confirmed individually. The tool can:

1. enable IPv6 on the active adapter
2. set Cloudflare DNS: `1.1.1.1`, `1.0.0.1`, `2606:4700:4700::1111`, `2606:4700:4700::1001`
3. set Teredo to `enterpriseclient` with `win10.ipv6.microsoft.com` and an automatic client port
4. start the required Xbox/network services

The tool does not uninstall programs, does not open ports manually and does not fully reset the firewall.

## Teredo and Group Policy

Many FH4 guides set Teredo via `gpedit.msc`. In that case `netsh` shows values like `enterpriseclient (Group Policy)`. This is fine as long as the type is `enterpriseclient`.

If the Group Policy forces a *different* value, action 3 cannot override it. Change it in `gpedit.msc` under
**Computer Configuration → Administrative Templates → Network → TCPIP Settings → IPv6 Transition Technologies**
(`Set Teredo State` = *Enterprise Client*, `Set Teredo Server Name` = `win10.ipv6.microsoft.com`), or set those policies to *Not Configured*.

## Diagnostic report and monitor

- Action `5` saves a diagnostic report.
- Action `6` starts the connection monitor. Press `M` in the monitor window when FH4 disconnects; stop it with `Ctrl+C`.

Reports and monitor logs are saved in the `Forza-Monitor` folder on your Windows desktop.

## Also check your router

The tool cannot change router settings. On a FRITZ!Box these settings usually make sense for the gaming PC:

- **Internet → Filters → Lists:** Teredo filter disabled
- **Home Network → Network → gaming PC:** "Permit independent port sharing for this device" enabled

On other routers: make sure UPnP is enabled and no Teredo/IPv6 tunnel filter is active. Don't set up an exposed host just for this.

## Important notes

- Teredo may show `dormant` while idle. What matters is the state while FH4 is online; ideally it should be `qualified`.
- `restricted (port)` behind NAT or `UPnP: No` in the Teredo output is not automatically an error.
- Cloudflare DNS is an optional diagnostic step. If your current DNS works reliably, you don't need to change it.
- The tool cannot fix problems on the FH4 servers, with your Microsoft account or caused by other software.
- Close or disable VPN software, virtual network adapters and torrent programs before testing.

## Privacy

All checks run locally. The helper only writes text/CSV files to your own desktop and uploads nothing. The diagnostic report intentionally does not determine your public IP address. Other technical details may still reveal information about your system; please review (and redact if needed) before sharing.

## Feedback and bug reports

Please include:

- Windows version
- Steam or Microsoft Store version of FH4
- screenshot of the helper overview or the diagnostic report
- the latest monitor CSV
- time and exact wording of the FH4 error message

## License

MIT License. See [LICENSE](LICENSE).
