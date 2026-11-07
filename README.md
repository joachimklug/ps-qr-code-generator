# QR Code Generator for PrusaSlicer

Create 3D-printable QR codes directly in PrusaSlicer. Customize the plate size, border width, base thickness, and height of the raised QR pattern.

PrusaSlicer added Lua plugins in **3.0.0-alpha11** and the in-app Plugin Marketplace in **3.0.0-alpha13**. See the [PrusaSlicer release notes](https://github.com/prusa3d/PrusaSlicer/releases/tag/version_3.0.0-alpha13#plugin-marketplace).

This QR code generator requires **PrusaSlicer 3.0.0-alpha14 or newer**.

## QR types

| Type | Status | What it’s for | Lua file |
| --- | --- | --- | --- |
| Text or URL | Available now | Store a note, part number, asset ID, or link | `text_or_url.lua` |
| vCard | Planned | Share contact details | `vcard.lua` |
| Wi-Fi (WLAN) | Planned | Help guests join a Wi-Fi network | `wlan.lua` |
| Location | Idea | Share a map pin | `geo.lua` |
| Email | Idea | Start an email with a recipient and optional subject | `email.lua` |
| Phone | Idea | Open the dialer with a number filled in | `phone.lua` |
| SMS | Idea | Start a text message to a number | `sms.lua` |
| Calendar event | Idea | Share event details someone can add to a calendar | `event.lua` |

Open **Generate-QR → Text or URL** in PrusaSlicer, enter a line of text or paste a link, and adjust the plate size, border, and height of the raised pattern.

## How it’s organized

Each QR command has a Lua file for its inputs and the data it encodes. The commands share `qrencode.lua` for encoding, `qr_geometry.lua` for building the raised pattern, and `utils.lua` for checking dimensions.

## VS Code setup

Install the Lua extension by sumneko and extract the PrusaSlicer Lua API 1.0.0 stubs outside the plugin directory. Follow [Prusa’s editor setup guide](https://plugin-marketplace.prusa3d.com/docs/editor-setup) for the download.

Copy [`.luarc.json.example`](.luarc.json.example) to `.luarc.json` and replace the example path with the absolute path to the extracted stubs folder. Reopen the project in VS Code to enable PrusaSlicer API completion and hover documentation. Git ignores `.luarc.json`. Keep both editor files out of the signed plugin ZIP.

## Support the project

If you find it handy, give the repo a star. Got an idea for another QR type or found a bug? Open an issue. Pull requests are welcome, too.
