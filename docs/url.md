# Text or URL QR generator

Create a 3D-printable QR code for a web address or a short piece of text, such as a part number or an asset ID. The generator adds a plate with a raised QR pattern to the PrusaSlicer build plate.

## Generate a code

1. In PrusaSlicer, open **Plugins → Generate-QR → Text or URL**.
2. Enter a full web address such as `https://example.com` or a single line of text such as `Asset ID 1042`.
3. Set the pattern size, borders, and heights, or use the defaults below.
4. Confirm the dialog to add the model to the build plate. Slice and print it, then scan the print to verify the link or text.

## Parameters

| Parameter | What it controls | Valid values | Default |
| --- | --- | --- | --- |
| **Text or URL** | The content stored in the QR code. | 1 to 1,024 bytes of text without control characters such as tabs or line breaks. | `https://example.com` |
| **QR pattern size (mm)** | The side length of the square QR pattern, excluding the borders. | Each QR module must be at least as wide as the printer’s nozzle. See the [model limits](../README.md#model-limits). | `80` |
| **Border: auto or mm (top, right, bottom, left)** | The clear space between the pattern and each edge of the plate. Scanners need this quiet zone to find the code. | Enter `auto` for four QR modules on every side, or a value in millimeters such as `5`. For different borders, enter four comma-separated values in **top, right, bottom, left** order. Each value can be `auto` or millimeters. For example, `auto, auto, 25, auto` adds 25 mm below the code for a label. Use nonnegative numbers and a decimal point for fractions. | `auto` |
| **Base plate height (mm)** | The thickness of the plate beneath the pattern. | At least 0.01 mm. | `2` |
| **Raised square height (mm)** | How far the QR squares rise above the plate. | At least 0.01 mm. Both heights together can be at most 1,000 mm. | `1` |
| **Two colors** (dropdown) | How the raised squares get a second color. | **Two colors: off** prints everything in one color. **Two colors: color change (one nozzle)** pauses the print for a filament change at the first layer of raised squares. **Two colors: second tool (multi-tool)** prints the raised squares with tool 2 on printers such as the INDX or XL. See [Two-color prints](../README.md#two-color-prints). | **Two colors: off** |
| **Keychain hole diameter (mm), 0 = none** | Adds a rounded tab with a hole for a key ring, centered above the plate. The tab sticks out of the plate, so the QR pattern and its border keep their size. See [Keychain hole](../README.md#keychain-hole). | `0` for no hole, or 1 to 30 mm. | `0` |

The text limit counts bytes. Some characters, such as accented letters or emoji, take up more than one byte.

Scanners guess the character encoding because the plugin doesn’t mark the text as UTF-8. Most phones show accented letters such as ä, ö, ü, and ß correctly, but some older scanners don’t. Scan the print to check.

## Plate dimensions

The plate width includes the QR pattern and the left and right borders. Its height in the top view includes the pattern and the top and bottom borders. With the default `auto` border, the plate size depends on how dense the code is. The default `https://example.com` makes a code of 25 × 25 modules, so the 80 mm pattern gets 12.8 mm borders and a **105.6 × 105.6 mm** plate. The total thickness at the raised squares is **3 mm** by default.

Borders narrower than four modules can make the code harder to scan. If you add text or graphics, keep them outside the four-module margin around the pattern. A module is one square in the QR grid.
