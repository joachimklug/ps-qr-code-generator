# QR Code Generator for PrusaSlicer

Create 3D-printable QR codes for text, links, and Wi-Fi directly in PrusaSlicer. Customize the plate size, border width, base thickness, and height of the raised QR pattern.

![Generated QR code on the build plate in PrusaSlicer](assets/qr-example.png)

PrusaSlicer added Lua plugins in **3.0.0-alpha11** and the in-app Plugin Marketplace in **3.0.0-alpha13**. See the [PrusaSlicer release notes](https://github.com/prusa3d/PrusaSlicer/releases/tag/version_3.0.0-alpha13#plugin-marketplace).

This QR code generator requires **PrusaSlicer 3.0.0-alpha14 or newer**.

## QR types

| Type | Status | What it’s for | Lua file |
| --- | --- | --- | --- |
| Text or URL | Available now | Store a note, part number, asset ID, or link | `text_or_url.lua` |
| Wi-Fi (WLAN) | Available now | Help guests join a Wi-Fi network | `wlan.lua` |
| vCard | Planned | Share contact details | `vcard.lua` |
| Location | Idea | Share a map pin | `geo.lua` |
| Email | Idea | Start an email with a recipient and optional subject | `email.lua` |
| Phone | Idea | Open the dialer with a number filled in | `phone.lua` |
| SMS | Idea | Start a text message to a number | `sms.lua` |
| Calendar event | Idea | Share event details someone can add to a calendar | `event.lua` |

Open **Generate-QR → Text or URL** in PrusaSlicer, enter a line of text or paste a link, and adjust the plate size, border, and height of the raised pattern.

### Wi-Fi

Open **Generate-QR → Wi-Fi** and enter the exact network name (SSID). Choose **WPA/WPA2 Personal**, **WPA3 Personal**, **WEP**, or **Open**, and enter the network password for a secured network. Check **Hidden network** if your router does not broadcast the SSID. Scanner support for WPA3 and WEP varies by device.

The QR code contains the network credentials in readable form. Anyone with the model or print can scan it to retrieve the password.

## How it’s organized

Each QR command has a Lua file at the bundle root for its inputs and the data it encodes. The shared code lives in `lib/`. The commands use `lib/qr_plate.lua` to build the plate with `lib/qrencode.lua` for encoding, `lib/qr_geometry.lua` for the raised pattern, and `lib/utils.lua` for dimension checks.

## VS Code setup

Install the Lua extension by sumneko and extract the PrusaSlicer Lua API 1.0.0 stubs outside the plugin directory. Follow [Prusa’s editor setup guide](https://plugin-marketplace.prusa3d.com/docs/editor-setup) for the download.

Copy [`.luarc.json.example`](.luarc.json.example) to `.luarc.json` and replace the example path with the absolute path to the extracted stubs folder. Reopen the project in VS Code to enable PrusaSlicer API completion and hover documentation. Git ignores `.luarc.json`. Keep both editor files out of the signed plugin ZIP.

## Support the project

If you find it handy, give the repo a star. Got an idea for another QR type or found a bug? Open an issue. Pull requests are welcome, too.
