-- PrusaSlicer provides require at execution time and resolves paths from the command file.
-- lib/qrencode.lua is vendored from speedata/luaqrcode. See lib/VENDORED.md.

-- Returns the smallest nozzle diameter of the selected printer, or nil if it is unknown.
-- This is a best-effort check, so API errors never block generating the plate.
local function find_smallest_nozzle_diameter()
    local ok, smallest = pcall(function()
        local result
        for _, tool in ipairs(api.project:current_bed():printer_config().tools) do
            local diameter = tool:nozzle_diameter()
            -- Ignore values that do not look like millimeters.
            if type(diameter) == "number" and diameter >= 0.05 and diameter <= 2
                and (result == nil or diameter < result) then
                result = diameter
            end
        end
        return result
    end)
    if ok then
        return smallest
    end
    return nil
end

local function encode(payload, encoding_error)
    local encoder = require("lib/qrencode")
    local ran, encoded, matrix = pcall(encoder.qrcode, payload)
    if ran and encoded then
        return matrix
    end

    -- pcall returns the error as its second value. qrcode returns false and a message.
    local reason = ran and matrix or encoded
    if type(reason) ~= "string" then
        error(encoding_error, 0)
    end
    if reason:find("Data too long", 1, true) then
        error("The content is too long for a QR code. Shorten it.", 0)
    end
    error(encoding_error .. " Details: " .. reason, 0)
end

local function add_qr_plate(payload, dimensions, encoding_error)
    local qr_geometry = require("lib/qr_geometry")
    local utils = require("lib/utils")

    local spec = utils.validate_dimensions(dimensions)
    local matrix = encode(payload, encoding_error)
    local layout = utils.resolve_layout(spec, #matrix, find_smallest_nozzle_diameter())

    local pattern_volumes = qr_geometry.make_pattern_volumes(matrix, {
        module_size = layout.module_size,
        border_left = layout.border_left,
        border_bottom = layout.border_bottom,
        base_height = spec.base_height,
        pattern_height = spec.pattern_height
    })
    api.project:add_object {
        mesh = api.make_cube(layout.plate_width, layout.plate_height, spec.base_height),
        other_volumes = pattern_volumes
    }
end

return { add_qr_plate = add_qr_plate }
