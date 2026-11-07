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

    local module_size = layout.qr_size / #matrix
    if module_size <= 0 then
        error("QR pattern size is too small.", 0)
    end

    api.project:add_object {
        mesh = api.make_cube(layout.plate_width, layout.plate_height, dimensions.base_height),
        other_volumes = qr_geometry.make_pattern_volumes(matrix, {
            module_size = module_size,
            border_left = layout.border_left,
            border_bottom = layout.border_bottom,
            base_height = dimensions.base_height,
            pattern_height = dimensions.pattern_height
        })
    }
end

return { add_qr_plate = add_qr_plate }
