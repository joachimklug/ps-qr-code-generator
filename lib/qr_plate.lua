local function add_qr_plate(payload, dimensions, encoding_error)
    -- PrusaSlicer provides require at execution time and resolves paths from the command file.
    -- Vendored encoder from speedata/luaqrcode at 5a9c34bc04d5113048df8528af72ef31d25b7300.
    local encoder = require("lib/qrencode")
    local qr_geometry = require("lib/qr_geometry")
    local utils = require("lib/utils")

    local layout = utils.resolve_layout(dimensions)

    local ran, encoded, matrix = pcall(encoder.qrcode, payload)
    if not ran or not encoded then
        error(encoding_error, 0)
    end

    local matrix_size = #matrix
    local min_qr_size = matrix_size * utils.MIN_FEATURE_SIZE
    -- Allow for floating-point rounding when the size is exactly at the minimum.
    if layout.qr_size + 1e-9 < min_qr_size then
        error(("Increase the QR pattern size to at least %.2f mm for this QR code."):format(min_qr_size), 0)
    end

    local pattern_volumes = qr_geometry.make_pattern_volumes(matrix, {
        module_size = layout.qr_size / matrix_size,
        border_left = layout.border_left,
        border_bottom = layout.border_bottom,
        base_height = dimensions.base_height,
        pattern_height = dimensions.pattern_height
    })
    api.project:add_object {
        mesh = api.make_cube(layout.plate_width, layout.plate_height, dimensions.base_height),
        other_volumes = pattern_volumes
    }
end

return { add_qr_plate = add_qr_plate }
