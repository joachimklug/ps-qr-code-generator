# Vendored code

## `qrencode.lua`

- **Upstream:** [speedata/luaqrcode](https://github.com/speedata/luaqrcode)
- **Commit:** `5a9c34bc04d5113048df8528af72ef31d25b7300`
- **License:** BSD-3-Clause. The upstream copyright notice is kept at the top of the file.

### Known local changes

- Upstream builds a 256 × 256 XOR lookup table when the module loads. Here, `get_xor_lookup()` builds it the first time it's needed, so loading the module while PrusaSlicer discovers plugins stays cheap. The bit-by-bit helper is named `byte_xor` instead of `slow_xor`.

When you update the encoder, diff the new upstream file against this one and carry these changes over. Add any new local change to this list.
