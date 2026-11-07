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
| **QR pattern size (mm)** | The side length of the square QR pattern, excluding the borders. | Any finite number greater than zero. Decimals are allowed. | `80` |
| **Border (top, right, bottom, left)** | The distance in millimeters from the pattern to each edge of the plate. | Enter `5` for 5 mm on every side, or enter four comma-separated values in **top, right, bottom, left** order. For example, `5, 5, 25, 5` gives 25 mm below the code and 5 mm on the other sides. Use nonnegative numbers and a decimal point for fractions. | `5` |
| **Base plate height (mm)** | The thickness of the plate beneath the pattern. | Any finite number greater than zero. Decimals are allowed. | `2` |
| **Raised square height (mm)** | How far the QR squares rise above the plate. | Any finite number greater than zero. Decimals are allowed. | `1` |

Contact fields cannot contain control characters such as tabs or line breaks. The complete encoded vCard can be at most 1,024 bytes, including formatting. Some characters, such as accented letters, take up more than one byte.

## Plate dimensions

The plate width includes the QR pattern and the left and right borders. Its height in the top view includes the pattern and the top and bottom borders. The default plate is **90 × 90 mm**, with a total thickness of **3 mm** at the raised squares.

If you add text or graphics, keep a clear margin of at least four QR modules around the pattern. A module is one square in the QR grid.
