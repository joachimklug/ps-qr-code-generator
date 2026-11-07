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
| **QR pattern size (mm)** | The side length of the square QR pattern, excluding the borders. | Any finite number greater than zero. Decimals are allowed. | `80` |
| **Border (top, right, bottom, left)** | The distance in millimeters from the pattern to each edge of the plate. | Enter `5` for 5 mm on every side, or enter four comma-separated values in **top, right, bottom, left** order. For example, `5, 5, 25, 5` gives 25 mm below the code and 5 mm on the other sides. Use nonnegative numbers and a decimal point for fractions. | `5` |
| **Base plate height (mm)** | The thickness of the plate beneath the pattern. | Any finite number greater than zero. Decimals are allowed. | `2` |
| **Raised square height (mm)** | How far the QR squares rise above the plate. | Any finite number greater than zero. Decimals are allowed. | `1` |

The text limit counts bytes. Some characters, such as accented letters or emoji, take up more than one byte.

## Plate dimensions

The plate width includes the QR pattern and the left and right borders. Its height in the top view includes the pattern and the top and bottom borders. The default plate is **90 × 90 mm**, with a total thickness of **3 mm** at the raised squares.

If you add text or graphics, keep a clear margin of at least four QR modules around the pattern. A module is one square in the QR grid.
