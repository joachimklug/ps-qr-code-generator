# Wi-Fi QR generator

Create a 3D-printable QR code that a compatible device can scan to join a Wi-Fi network. The generator adds a plate with a raised QR pattern to the PrusaSlicer build plate.

Anyone who can scan the model or print can read the encoded network credentials. Share it only with people you want to give access to the network.

## Generate a code

1. In PrusaSlicer, open **Plugins → Generate-QR → Wi-Fi**.
2. Enter the exact network name, including its capitalization and any spaces.
3. Choose the security type configured on the network. Enter the network password or key for a secured network. Leave the password blank for **Open**.
4. Check **Hidden network** if the network does not broadcast its name.
5. Set the pattern size, borders, and heights, or use the defaults below.
6. Confirm the dialog to add the model to the build plate. Slice and print it, then scan the print with a device you want to connect.

## Parameters

| Parameter | What it controls | Valid values | Plugin default |
| --- | --- | --- | --- |
| **Network name (SSID)** | The name of the network the device should join. | 1 to 32 bytes without control characters such as tabs or line breaks. | Blank |
| **Security** | The security type encoded for the network. | **WPA/WPA2 Personal**, **WPA3 Personal**, **WEP**, or **Open**. | — |
| **Wi-Fi password (leave blank for Open)** | The password or key stored in the code. | See the password and key requirements below. | Blank |
| **Hidden network** | Whether the code identifies the network as hidden. | Checked for a hidden network. Unchecked for a network that broadcasts its name. | Unchecked |
| **QR pattern size (mm)** | The side length of the square QR pattern, excluding the borders. | Each QR module must be at least as wide as the printer’s nozzle. See the [model limits](../README.md#model-limits). | `80` |
| **Border: auto or mm (top, right, bottom, left)** | The clear space between the pattern and each edge of the plate. Scanners need this quiet zone to find the code. | Enter `auto` for four QR modules on every side, or a value in millimeters such as `5`. For different borders, enter four comma-separated values in **top, right, bottom, left** order. Each value can be `auto` or millimeters. For example, `auto, auto, 25, auto` adds 25 mm below the code for a label. Use nonnegative numbers and a decimal point for fractions. | `auto` |
| **Base plate height (mm)** | The thickness of the plate beneath the pattern. | At least 0.01 mm. | `2` |
| **Raised square height (mm)** | How far the QR squares rise above the plate. | At least 0.01 mm. Both heights together can be at most 1,000 mm. | `1` |
| **Two colors** (dropdown) | How the raised squares get a second color. | **Two colors: off** prints everything in one color. **Two colors: color change (one nozzle)** pauses the print for a filament change at the first layer of raised squares. **Two colors: second tool (multi-tool)** prints the raised squares with tool 2 on printers such as the INDX or XL. See [Two-color prints](../README.md#two-color-prints). | **Two colors: off** |
| **Keychain hole diameter (mm), 0 = none** | Adds a rounded tab with a hole for a key ring, centered above the plate. The tab sticks out of the plate, so the QR pattern and its border keep their size. See [Keychain hole](../README.md#keychain-hole). | `0` for no hole, or 1 to 30 mm. | `0` |

### Password and key requirements

| Security type | Values accepted by the generator |
| --- | --- |
| **WPA/WPA2 Personal** | A password of 8 to 63 bytes or a key of exactly 64 hexadecimal digits. |
| **WPA3 Personal** | The network password. The generator accepts 1 to 1,024 bytes, except exactly 64 hexadecimal digits, which scanners read as a raw WPA key. The code uses the WPA type, which all common scanners understand and which also works on WPA2/WPA3 mixed networks. Some phones only accept passwords of 8 to 63 bytes for this type. |
| **WEP** | A key of 5, 13, or 29 bytes, or 10, 26, or 58 hexadecimal digits. |
| **Open** | Leave the field blank. The generator ignores any value in it. |

Passwords and keys cannot contain control characters such as tabs or line breaks. Some characters take up more than one byte. Scanner support for **WEP** varies by device.

## Plate dimensions

The plate width includes the QR pattern and the left and right borders. Its height in the top view includes the pattern and the top and bottom borders. With the default `auto` border, the plate size depends on how dense the code is. For example, a code of 33 × 33 modules with the 80 mm pattern gets 9.7 mm borders and a plate of about 99.4 × 99.4 mm. The total thickness at the raised squares is **3 mm** by default.

Borders narrower than four modules can make the code harder to scan. If you add a network label, keep it outside the four-module margin around the pattern. A module is one square in the QR grid.
