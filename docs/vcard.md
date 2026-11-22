# vCard QR generator

Create a 3D-printable QR code that stores contact details in vCard 3.0 format. A compatible scanner can offer to save the details as a contact. Anyone who scans the code can read the details you enter.

## Generate a code

1. In PrusaSlicer, open **Plugins → Generate-QR → vCard**.
2. Enter a first name, a last name, or both. Fill in the contact details you want to share and leave the other fields blank.
3. Set the pattern size, borders, and heights, or use the defaults below.
4. Confirm the dialog to add the model to the build plate. Slice and print it, then scan the print to verify the contact details.

## Parameters

| Parameter | What it controls | Valid values | Default |
| --- | --- | --- | --- |
| **First name** | The contact’s given name. | Single-line text. Required only if **Last name** is blank. | Blank |
| **Last name** | The contact’s family name. | Single-line text. Required only if **First name** is blank. | Blank |
| **Organization** | The company or organization associated with the contact. | Single-line text or blank. | Blank |
| **Job title** | The contact’s job title. | Single-line text or blank. | Blank |
| **Phone number** | The contact’s telephone number. | Digits with an optional leading `+`. Spaces, parentheses, periods, and hyphens are allowed. For example, `+1 202 555 0148`. Leave blank to omit it. | Blank |
| **Email address** | The contact’s email address. | An address such as `name@example.com` with one `@` and no spaces or angle brackets, or blank. | Blank |
| **Website URL** | The website associated with the contact. | A full address starting with `http://` or `https://`, such as `https://example.com`, or blank. | Blank |
| **QR pattern size (mm)** | The side length of the square QR pattern, excluding the borders. | Each QR module must be at least as wide as the printer’s nozzle. See the [model limits](../README.md#model-limits). | `80` |
| **Border: auto or mm (top, right, bottom, left)** | The clear space between the pattern and each edge of the plate. Scanners need this quiet zone to find the code. | Enter `auto` for four QR modules on every side, or a value in millimeters such as `5`. For different borders, enter four comma-separated values in **top, right, bottom, left** order. Each value can be `auto` or millimeters. For example, `auto, auto, 25, auto` adds 25 mm below the code for a label. Use nonnegative numbers and a decimal point for fractions. | `auto` |
| **Base plate height (mm)** | The thickness of the plate beneath the pattern. | At least 0.01 mm. | `2` |
| **Raised square height (mm)** | How far the QR squares rise above the plate. | At least 0.01 mm. Both heights together can be at most 1,000 mm. | `1` |
| **Two colors** (dropdown) | How the raised squares get a second color. | **Two colors: off** prints everything in one color. **Two colors: color change (one nozzle)** pauses the print for a filament change at the first layer of raised squares. **Two colors: second tool (multi-tool)** prints the raised squares with tool 2 on printers such as the INDX or XL. See [Two-color prints](../README.md#two-color-prints). | **Two colors: off** |

Contact fields cannot contain control characters such as tabs or line breaks. The complete encoded vCard can be at most 1,024 bytes, including formatting. Some characters, such as accented letters, take up more than one byte.

Scanners guess the character encoding because the plugin doesn’t mark the text as UTF-8. Most phones show accented letters such as ä, ö, ü, and ß correctly, but some older scanners don’t. Scan the print to check.

## Plate dimensions

The plate width includes the QR pattern and the left and right borders. Its height in the top view includes the pattern and the top and bottom borders. With the default `auto` border, the plate size depends on how dense the code is. Contact details usually make dense codes. For example, a code of 45 × 45 modules with the 80 mm pattern gets 7.1 mm borders and a plate of about 94.2 × 94.2 mm. The total thickness at the raised squares is **3 mm** by default.

Borders narrower than four modules can make the code harder to scan. If you add text or graphics, keep them outside the four-module margin around the pattern. A module is one square in the QR grid.
