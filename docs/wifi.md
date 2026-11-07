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
| **QR pattern size (mm)** | The side length of the square QR pattern, excluding the borders. | Any finite number greater than zero. Decimals are allowed. | `80` |
| **Border (top, right, bottom, left)** | The distance in millimeters from the pattern to each edge of the plate. | Enter `5` for 5 mm on every side, or enter four comma-separated values in **top, right, bottom, left** order. For example, `5, 5, 25, 5` gives 25 mm below the code and 5 mm on the other sides. Use nonnegative numbers and a decimal point for fractions. | `5` |
| **Base plate height (mm)** | The thickness of the plate beneath the pattern. | Any finite number greater than zero. Decimals are allowed. | `2` |
| **Raised square height (mm)** | How far the QR squares rise above the plate. | Any finite number greater than zero. Decimals are allowed. | `1` |

### Password and key requirements

| Security type | Values accepted by the generator |
| --- | --- |
| **WPA/WPA2 Personal** | A password of 8 to 63 bytes or a key of exactly 64 hexadecimal digits. |
| **WPA3 Personal** | The network password. The generator accepts 1 to 1,024 bytes. |
| **WEP** | A key of 5, 13, or 29 bytes, or 10, 26, or 58 hexadecimal digits. |
| **Open** | Leave the field blank. The generator ignores any value in it. |

Passwords and keys cannot contain control characters such as tabs or line breaks. Some characters take up more than one byte. Scanner support for **WPA3 Personal** and **WEP** varies by device.

## Plate dimensions

The plate width includes the QR pattern and the left and right borders. Its height in the top view includes the pattern and the top and bottom borders. The default plate is **90 × 90 mm**, with a total thickness of **3 mm** at the raised squares.

If you add a network label, keep a clear margin of at least four QR modules around the pattern. A module is one square in the QR grid.
